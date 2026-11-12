package br.uninovet;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

// Upload (veterinario) e download de documentos pelo painel da clinica.
// O token CSRF vai na URL do upload porque o formulario e multipart.
@WebServlet({"/documentos/enviar", "/documentos/baixar"})
@MultipartConfig(maxFileSize = Documentos.TAMANHO_MAXIMO_BYTES, maxRequestSize = Documentos.TAMANHO_MAXIMO_BYTES + 4096)
public class PainelDocumentos extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Usuario usuario = (Usuario) req.getAttribute("usuario");
        String base = Painel.base(req);
        try {
            int consultaId = Integer.parseInt(req.getParameter("consulta_id"));
            Part arquivo = req.getPart("arquivo");
            if (arquivo == null || arquivo.getSubmittedFileName() == null) {
                throw ErroNegocio.invalido("Escolha um arquivo.");
            }
            try (InputStream conteudo = arquivo.getInputStream()) {
                Documentos.salvar(usuario, consultaId, req.getParameter("tipo"),
                        arquivo.getSubmittedFileName(), conteudo);
            }
            req.getSession().setAttribute("aviso", "Documento anexado.");
        } catch (ErroNegocio e) {
            req.getSession().setAttribute("erro", e.getMessage());
        } catch (Exception e) {
            System.out.println("[Painel] erro no upload: " + e);
            req.getSession().setAttribute("erro", "Nao foi possivel anexar o documento (maximo 5 MB).");
        }
        String destino = Painel.destinoSeguro(req.getParameter("voltar"), "/agenda");
        Painel.redirecionar(resp, base + destino);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Usuario usuario = (Usuario) req.getAttribute("usuario");
        try {
            int id = Integer.parseInt(req.getParameter("id"));
            Documentos.Arquivo documento = Documentos.abrir(usuario, id);
            resp.setContentType(documento.tipoConteudo);
            resp.setHeader("Content-Disposition", "attachment; filename=\"" + documento.nomeOriginal + "\"");
            resp.setHeader("X-Content-Type-Options", "nosniff");
            Files.copy(documento.arquivo.toPath(), resp.getOutputStream());
        } catch (ErroNegocio e) {
            resp.sendError(e.status, e.getMessage());
        } catch (Exception e) {
            resp.sendError(404, "Documento nao encontrado.");
        }
    }
}
