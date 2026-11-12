package br.uninovet;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// Listas que o app precisa para montar telas: servicos, veterinarios, pets e
// horarios livres.
@WebServlet({"/api/tipos-servico", "/api/veterinarios", "/api/pets", "/api/horarios"})
public class ApiCatalogo extends ApiBase {

    @Override
    protected void executar(HttpServletRequest req, HttpServletResponse resp, Usuario usuario) throws Exception {
        String rota = req.getServletPath();
        String metodo = req.getMethod();

        if ("/api/pets".equals(rota) && "POST".equals(metodo)) {
            cadastrarPet(req, resp, usuario);
            return;
        }
        if (!"GET".equals(metodo)) {
            metodoNaoPermitido(resp);
            return;
        }
        if ("/api/tipos-servico".equals(rota)) {
            consultar(resp, "SELECT id, nome, categoria, duracao_minutos FROM tipo_servico "
                    + "WHERE ativo = 1 ORDER BY nome", null);
        } else if ("/api/veterinarios".equals(rota)) {
            consultar(resp, "SELECT id, nome, crmv, especialidade FROM veterinario ORDER BY nome", null);
        } else if ("/api/pets".equals(rota)) {
            listarPets(resp, usuario);
        } else {
            listarHorarios(req, resp);
        }
    }

    private void consultar(HttpServletResponse resp, String sql, Integer parametro) throws Exception {
        try (Connection conexao = Banco.abrir()) {
            PreparedStatement comando = conexao.prepareStatement(sql);
            if (parametro != null) {
                comando.setInt(1, parametro);
            }
            Json.dados(resp, 200, Json.linhas(comando.executeQuery()));
        }
    }

    // Cliente ve so os pets dele; veterinario so os que atendeu; equipe ve todos.
    private void listarPets(HttpServletResponse resp, Usuario usuario) throws Exception {
        String base = "SELECT a.id, a.nome, a.especie, a.raca, a.tutor_id, t.nome AS tutor "
                + "FROM animal a JOIN tutor t ON t.id = a.tutor_id ";
        if (usuario.isCliente()) {
            consultar(resp, base + "WHERE a.tutor_id = ? ORDER BY a.nome", usuario.tutorId);
        } else if (usuario.isVeterinario()) {
            consultar(resp, base + "WHERE a.id IN (SELECT animal_id FROM consulta WHERE veterinario_id = ?) "
                    + "ORDER BY a.nome", usuario.veterinarioId);
        } else {
            consultar(resp, base + "ORDER BY a.nome", null);
        }
    }

    private void cadastrarPet(HttpServletRequest req, HttpServletResponse resp, Usuario usuario) throws Exception {
        if (!usuario.isCliente()) {
            throw ErroNegocio.proibido("Somente o tutor cadastra o proprio pet pelo app.");
        }
        String nome = req.getParameter("nome");
        String especie = req.getParameter("especie");
        String raca = req.getParameter("raca");
        boolean isNomeVazio = nome == null || nome.trim().isEmpty() || nome.length() > 80;
        boolean isEspecieVazia = especie == null || especie.trim().isEmpty() || especie.length() > 40;
        if (isNomeVazio || isEspecieVazia) {
            throw ErroNegocio.invalido("Informe o nome e a especie do pet.");
        }
        if (raca != null && raca.length() > 60) {
            throw ErroNegocio.invalido("Raca muito longa.");
        }
        try (Connection conexao = Banco.abrir()) {
            PreparedStatement comando = conexao.prepareStatement(
                    "INSERT INTO animal (nome, especie, raca, tutor_id) VALUES (?, ?, ?, ?)",
                    Statement.RETURN_GENERATED_KEYS);
            comando.setString(1, nome.trim());
            comando.setString(2, especie.trim());
            String racaLimpa = raca == null || raca.trim().isEmpty() ? null : raca.trim();
            comando.setString(3, racaLimpa);
            comando.setInt(4, usuario.tutorId);
            comando.executeUpdate();
            java.sql.ResultSet chaves = comando.getGeneratedKeys();
            chaves.next();
            Map<String, Object> dados = new LinkedHashMap<>();
            dados.put("id", chaves.getInt(1));
            Json.dados(resp, 201, dados);
        }
    }

    private void listarHorarios(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        int veterinarioId = inteiro(req, "veterinario_id");
        int tipoServicoId = inteiro(req, "tipo_servico_id");
        String dia = req.getParameter("data");
        if (dia == null) {
            throw ErroNegocio.invalido("Informe a data (aaaa-mm-dd).");
        }
        try (Connection conexao = Banco.abrir()) {
            int duracao = Agenda.duracaoDoServico(conexao, tipoServicoId);
            List<String> livres = Agenda.horariosLivres(conexao, veterinarioId, Agenda.lerDia(dia), duracao);
            Json.dados(resp, 200, livres);
        }
    }
}
