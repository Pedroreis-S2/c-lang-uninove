package br.uninovet;

import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// Agendamentos (consultas e servicos) do aplicativo.
//   GET  /api/agendamentos                      lista o que o usuario pode ver
//   POST /api/agendamentos                      cliente solicita; equipe agenda direto
//   POST /api/agendamentos/{id}/aceitar|recusar|cancelar|concluir
//   GET  /api/agendamentos/{id}/documentos      lista documentos da consulta
//   POST /api/agendamentos/{id}/documentos      veterinario anexa (corpo = arquivo)
@WebServlet("/api/agendamentos/*")
public class ApiAgendamentos extends ApiBase {

    @Override
    protected void executar(HttpServletRequest req, HttpServletResponse resp, Usuario usuario) throws Exception {
        String caminho = req.getPathInfo();
        boolean isRaiz = caminho == null || "/".equals(caminho);
        String metodo = req.getMethod();

        if (isRaiz && "GET".equals(metodo)) {
            Json.dados(resp, 200, Consultas.listar(usuario));
        } else if (isRaiz && "POST".equals(metodo)) {
            criar(req, resp, usuario);
        } else if (!isRaiz) {
            String[] partes = caminho.substring(1).split("/");
            boolean isRotaDeConsulta = partes.length == 2;
            if (!isRotaDeConsulta) {
                throw ErroNegocio.naoEncontrado("Rota nao encontrada.");
            }
            int id = lerId(partes[0]);
            rotaDaConsulta(req, resp, usuario, id, partes[1]);
        } else {
            metodoNaoPermitido(resp);
        }
    }

    private void criar(HttpServletRequest req, HttpServletResponse resp, Usuario usuario) throws Exception {
        int animalId = inteiro(req, "animal_id");
        int veterinarioId = inteiro(req, "veterinario_id");
        int tipoServicoId = inteiro(req, "tipo_servico_id");
        String dataHora = req.getParameter("data_hora");
        String motivo = req.getParameter("motivo");
        int id = Consultas.criar(usuario, animalId, veterinarioId, tipoServicoId, dataHora, motivo);
        Map<String, Object> dados = new LinkedHashMap<>();
        dados.put("id", id);
        dados.put("status", usuario.isCliente() ? "SOLICITADA" : "AGENDADA");
        Json.dados(resp, 201, dados);
    }

    private void rotaDaConsulta(HttpServletRequest req, HttpServletResponse resp, Usuario usuario, int id,
            String acao) throws Exception {
        String metodo = req.getMethod();
        if ("documentos".equals(acao) && "GET".equals(metodo)) {
            Json.dados(resp, 200, Documentos.listar(usuario, id));
            return;
        }
        if ("documentos".equals(acao) && "POST".equals(metodo)) {
            String tipo = req.getParameter("tipo");
            String nome = req.getParameter("nome");
            int documentoId = Documentos.salvar(usuario, id, tipo, nome, req.getInputStream());
            Map<String, Object> dados = new LinkedHashMap<>();
            dados.put("id", documentoId);
            Json.dados(resp, 201, dados);
            return;
        }
        if (!"POST".equals(metodo)) {
            metodoNaoPermitido(resp);
            return;
        }
        if ("aceitar".equals(acao)) {
            Consultas.aceitar(usuario, id);
        } else if ("recusar".equals(acao)) {
            Consultas.recusar(usuario, id, req.getParameter("motivo"));
        } else if ("cancelar".equals(acao)) {
            Consultas.cancelar(usuario, id);
        } else if ("concluir".equals(acao)) {
            Consultas.concluir(usuario, id);
        } else {
            throw ErroNegocio.naoEncontrado("Rota nao encontrada.");
        }
        Map<String, Object> dados = new LinkedHashMap<>();
        dados.put("id", id);
        Json.dados(resp, 200, dados);
    }

    private int lerId(String texto) {
        try {
            return Integer.parseInt(texto);
        } catch (Exception e) {
            throw ErroNegocio.naoEncontrado("Consulta nao encontrada.");
        }
    }
}
