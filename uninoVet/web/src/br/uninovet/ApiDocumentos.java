package br.uninovet;

import java.nio.file.Files;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// Documentos pelo app. So entrega para quem tem acesso a consulta (dono,
// veterinario ou equipe).
//   GET /api/documentos/{id}/link     devolve um link temporario (2 min) para baixar
//   GET /api/documentos/{id}/arquivo  baixa o arquivo (link assinado, sem token)
//   GET /api/documentos/{id}          baixa o arquivo (com token no cabecalho)
@WebServlet("/api/documentos/*")
public class ApiDocumentos extends ApiBase {

    @Override
    protected void executar(HttpServletRequest req, HttpServletResponse resp, Usuario usuario) throws Exception {
        String caminho = req.getPathInfo();
        if (!"GET".equals(req.getMethod()) || caminho == null || caminho.length() < 2) {
            metodoNaoPermitido(resp);
            return;
        }
        String[] partes = caminho.substring(1).split("/");
        int id = lerId(partes[0]);
        boolean isSemAcao = partes.length == 1;
        String acao = isSemAcao ? "" : partes[1];

        if ("link".equals(acao)) {
            Map<String, Object> dados = new LinkedHashMap<>();
            dados.put("url", Documentos.gerarLink(usuario, id));
            Json.dados(resp, 200, dados);
        } else if ("arquivo".equals(acao)) {
            Documentos.Arquivo documento = Documentos.abrirComLink(id, req.getParameter("exp"),
                    req.getParameter("sig"));
            enviar(resp, documento);
        } else if (isSemAcao) {
            enviar(resp, Documentos.abrir(usuario, id));
        } else {
            throw ErroNegocio.naoEncontrado("Rota nao encontrada.");
        }
    }

    private void enviar(HttpServletResponse resp, Documentos.Arquivo documento) throws Exception {
        resp.setContentType(documento.tipoConteudo);
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + documento.nomeOriginal + "\"");
        resp.setHeader("X-Content-Type-Options", "nosniff");
        Files.copy(documento.arquivo.toPath(), resp.getOutputStream());
    }

    private int lerId(String texto) {
        try {
            return Integer.parseInt(texto);
        } catch (Exception e) {
            throw ErroNegocio.naoEncontrado("Documento nao encontrado.");
        }
    }
}
