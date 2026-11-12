package br.uninovet;

import java.io.IOException;
import java.security.MessageDigest;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

// Porta de entrada do painel da clinica (tudo fora de /api): exige login de
// funcionario, restringe /admin ao gerente e confere o token CSRF nos POSTs.
@WebFilter("/*")
public class FiltroPainel implements Filter {

    @Override
    public void doFilter(ServletRequest requisicao, ServletResponse resposta, FilterChain cadeia)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) requisicao;
        HttpServletResponse resp = (HttpServletResponse) resposta;

        String caminho = req.getServletPath();
        if (caminho.startsWith("/api/")) {
            cadeia.doFilter(requisicao, resposta);
            return;
        }

        String base = Painel.base(req);
        req.setAttribute("base", base);

        boolean isPublico = "/login".equals(caminho) || "/estilo.css".equals(caminho);
        if (isPublico) {
            cadeia.doFilter(requisicao, resposta);
            return;
        }

        HttpSession sessao = req.getSession(false);
        Usuario usuario = sessao == null ? null : (Usuario) sessao.getAttribute("usuario");
        if (usuario == null) {
            Painel.redirecionar(resp, base + "/login");
            return;
        }
        boolean isAdmin = caminho.startsWith("/admin");
        if (isAdmin && !usuario.isGerente()) {
            resp.sendError(403, "Somente o gerente acessa o painel administrativo.");
            return;
        }
        if ("POST".equals(req.getMethod()) && !tokenCsrfConfere(req, sessao)) {
            resp.sendError(403, "Formulario expirado. Volte e tente de novo.");
            return;
        }
        req.setAttribute("usuario", usuario);
        req.setAttribute("csrf", sessao.getAttribute("csrf"));
        cadeia.doFilter(requisicao, resposta);
    }

    private boolean tokenCsrfConfere(HttpServletRequest req, HttpSession sessao) {
        String esperado = (String) sessao.getAttribute("csrf");
        String recebido = req.getParameter("csrf");
        if (esperado == null || recebido == null) {
            return false;
        }
        return MessageDigest.isEqual(esperado.getBytes(), recebido.getBytes());
    }
}
