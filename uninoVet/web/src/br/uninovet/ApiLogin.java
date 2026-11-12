package br.uninovet;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// Login, cadastro de cliente, logout e "quem sou eu" do aplicativo.
@WebServlet({"/api/login", "/api/cadastro", "/api/logout", "/api/eu"})
public class ApiLogin extends ApiBase {

    @Override
    protected void executar(HttpServletRequest req, HttpServletResponse resp, Usuario usuario) throws Exception {
        String rota = req.getServletPath();
        boolean isPost = "POST".equals(req.getMethod());

        if ("/api/eu".equals(rota) && "GET".equals(req.getMethod())) {
            Json.dados(resp, 200, usuario.paraJson());
        } else if ("/api/login".equals(rota) && isPost) {
            entrar(req, resp);
        } else if ("/api/cadastro".equals(rota) && isPost) {
            cadastrar(req, resp);
        } else if ("/api/logout".equals(rota) && isPost) {
            Acesso.encerrarToken(Acesso.tokenDaRequisicao(req));
            Json.dados(resp, 200, "ok");
        } else {
            metodoNaoPermitido(resp);
        }
    }

    private void entrar(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        Usuario usuario = Acesso.autenticar(req.getParameter("email"), req.getParameter("senha"));
        if (usuario == null) {
            Json.erro(resp, 401, "E-mail ou senha incorretos.");
            return;
        }
        responderComToken(resp, 200, usuario);
    }

    // Cadastro publico cria somente CLIENTE (usuario + tutor). Funcionarios sao criados pelo gerente.
    private void cadastrar(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String nome = textoObrigatorio(req, "nome", 120);
        String telefone = textoObrigatorio(req, "telefone", 20);
        String email = textoObrigatorio(req, "email", 120).toLowerCase();
        String senha = req.getParameter("senha");
        if (!email.contains("@") || email.startsWith("@") || email.endsWith("@")) {
            throw ErroNegocio.invalido("E-mail invalido.");
        }
        if (senha == null || senha.length() < 6) {
            throw ErroNegocio.invalido("A senha precisa ter pelo menos 6 caracteres.");
        }

        try (Connection conexao = Banco.abrir()) {
            PreparedStatement existente = conexao.prepareStatement("SELECT id FROM usuario WHERE email = ?");
            existente.setString(1, email);
            if (existente.executeQuery().next()) {
                throw ErroNegocio.conflito("Ja existe uma conta com esse e-mail.");
            }
            conexao.setAutoCommit(false);
            PreparedStatement novoUsuario = conexao.prepareStatement(
                    "INSERT INTO usuario (nome, email, senha_hash, perfil) VALUES (?, ?, ?, 'CLIENTE')",
                    Statement.RETURN_GENERATED_KEYS);
            novoUsuario.setString(1, nome);
            novoUsuario.setString(2, email);
            novoUsuario.setString(3, Senha.gerarHash(senha));
            novoUsuario.executeUpdate();
            ResultSet chaves = novoUsuario.getGeneratedKeys();
            chaves.next();
            int usuarioId = chaves.getInt(1);

            PreparedStatement novoTutor = conexao.prepareStatement(
                    "INSERT INTO tutor (nome, telefone, email, usuario_id) VALUES (?, ?, ?, ?)");
            novoTutor.setString(1, nome);
            novoTutor.setString(2, telefone);
            novoTutor.setString(3, email);
            novoTutor.setInt(4, usuarioId);
            novoTutor.executeUpdate();
            conexao.commit();
        }
        Usuario usuario = Acesso.autenticar(email, senha);
        responderComToken(resp, 201, usuario);
    }

    private void responderComToken(HttpServletResponse resp, int status, Usuario usuario) throws Exception {
        Map<String, Object> dados = new LinkedHashMap<>();
        dados.put("token", Acesso.criarToken(usuario.id));
        dados.put("usuario", usuario.paraJson());
        Json.dados(resp, status, dados);
    }

    private String textoObrigatorio(HttpServletRequest req, String campo, int maximo) {
        String valor = req.getParameter(campo);
        if (valor == null || valor.trim().isEmpty() || valor.length() > maximo) {
            throw ErroNegocio.invalido("Preencha o campo: " + campo);
        }
        return valor.trim();
    }
}
