package br.uninovet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// Todas as acoes (POST) do painel da clinica. As regras vivem em Consultas e
// Agenda, as mesmas da API; aqui so traduzimos formulario -> chamada.
@WebServlet("/acoes")
public class PainelAcoes extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Usuario usuario = (Usuario) req.getAttribute("usuario");
        String acao = req.getParameter("acao");
        String base = Painel.base(req);
        String destino = Painel.destinoSeguro(req.getParameter("voltar"), "/painel");
        try {
            String aviso = executar(req, usuario, acao);
            req.getSession().setAttribute("aviso", aviso);
        } catch (ErroNegocio e) {
            req.getSession().setAttribute("erro", e.getMessage());
        } catch (Exception e) {
            System.out.println("[Painel] erro na acao " + acao + ": " + e);
            e.printStackTrace();
            req.getSession().setAttribute("erro", "Nao foi possivel concluir a acao.");
        }
        Painel.redirecionar(resp, base + destino);
    }

    private String executar(HttpServletRequest req, Usuario usuario, String acao) throws Exception {
        if ("aceitar".equals(acao)) {
            Consultas.aceitar(usuario, inteiro(req, "id"));
            return "Solicitacao aceita: o horario foi reservado.";
        }
        if ("recusar".equals(acao)) {
            Consultas.recusar(usuario, inteiro(req, "id"), req.getParameter("motivo"));
            return "Solicitacao recusada.";
        }
        if ("cancelar".equals(acao)) {
            Consultas.cancelar(usuario, inteiro(req, "id"));
            return "Consulta cancelada.";
        }
        if ("concluir".equals(acao)) {
            Consultas.concluir(usuario, inteiro(req, "id"));
            return "Consulta concluida.";
        }
        if ("agendar".equals(acao)) {
            Consultas.criar(usuario, inteiro(req, "animal_id"), inteiro(req, "veterinario_id"),
                    inteiro(req, "tipo_servico_id"), req.getParameter("data_hora"), req.getParameter("motivo"));
            return "Agendamento criado.";
        }
        if ("criar_usuario".equals(acao)) {
            criarUsuario(req, usuario);
            return "Usuario criado.";
        }
        if ("alternar_usuario".equals(acao)) {
            alternarUsuario(usuario, inteiro(req, "id"));
            return "Usuario atualizado.";
        }
        throw ErroNegocio.invalido("Acao desconhecida.");
    }

    // Gerente cria secretario, veterinario ou outro gerente (cliente se cadastra sozinho no app).
    private void criarUsuario(HttpServletRequest req, Usuario usuario) throws Exception {
        if (!usuario.isGerente()) {
            throw ErroNegocio.proibido("Somente o gerente cria usuarios.");
        }
        String nome = obrigatorio(req, "nome", 120);
        String email = obrigatorio(req, "email", 120).toLowerCase();
        String perfil = req.getParameter("perfil");
        String senha = req.getParameter("senha");
        boolean isPerfilValido = Usuario.SECRETARIO.equals(perfil) || Usuario.VETERINARIO.equals(perfil)
                || Usuario.GERENTE.equals(perfil);
        if (!isPerfilValido) {
            throw ErroNegocio.invalido("Perfil invalido.");
        }
        if (!email.contains("@")) {
            throw ErroNegocio.invalido("E-mail invalido.");
        }
        if (senha == null || senha.length() < 6) {
            throw ErroNegocio.invalido("A senha precisa ter pelo menos 6 caracteres.");
        }
        try (Connection conexao = Banco.abrir()) {
            PreparedStatement existente = conexao.prepareStatement("SELECT id FROM usuario WHERE email = ?");
            existente.setString(1, email);
            if (existente.executeQuery().next()) {
                throw ErroNegocio.conflito("Ja existe um usuario com esse e-mail.");
            }
            conexao.setAutoCommit(false);
            PreparedStatement novo = conexao.prepareStatement(
                    "INSERT INTO usuario (nome, email, senha_hash, perfil) VALUES (?, ?, ?, ?)",
                    Statement.RETURN_GENERATED_KEYS);
            novo.setString(1, nome);
            novo.setString(2, email);
            novo.setString(3, Senha.gerarHash(senha));
            novo.setString(4, perfil);
            novo.executeUpdate();
            ResultSet chaves = novo.getGeneratedKeys();
            chaves.next();
            int usuarioId = chaves.getInt(1);
            if (Usuario.VETERINARIO.equals(perfil)) {
                PreparedStatement veterinario = conexao.prepareStatement(
                        "INSERT INTO veterinario (nome, crmv, especialidade, usuario_id) VALUES (?, ?, ?, ?)");
                veterinario.setString(1, nome);
                veterinario.setString(2, obrigatorio(req, "crmv", 20));
                veterinario.setString(3, obrigatorio(req, "especialidade", 80));
                veterinario.setInt(4, usuarioId);
                veterinario.executeUpdate();
            }
            conexao.commit();
        }
    }

    private void alternarUsuario(Usuario usuario, int id) throws Exception {
        if (!usuario.isGerente()) {
            throw ErroNegocio.proibido("Somente o gerente altera usuarios.");
        }
        if (usuario.id == id) {
            throw ErroNegocio.invalido("Voce nao pode desativar o proprio usuario.");
        }
        try (Connection conexao = Banco.abrir()) {
            PreparedStatement comando = conexao.prepareStatement("UPDATE usuario SET ativo = 1 - ativo WHERE id = ?");
            comando.setInt(1, id);
            comando.executeUpdate();
        }
    }

    private int inteiro(HttpServletRequest req, String campo) {
        try {
            return Integer.parseInt(req.getParameter(campo).trim());
        } catch (Exception e) {
            throw ErroNegocio.invalido("Preencha o campo: " + campo);
        }
    }

    private String obrigatorio(HttpServletRequest req, String campo, int maximo) {
        String valor = req.getParameter(campo);
        if (valor == null || valor.trim().isEmpty() || valor.length() > maximo) {
            throw ErroNegocio.invalido("Preencha o campo: " + campo);
        }
        return valor.trim();
    }
}
