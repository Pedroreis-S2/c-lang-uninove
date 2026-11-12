package br.uninovet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

// Login e logout do painel da clinica (sessao por cookie).
// Clientes usam o aplicativo; aqui entram veterinario, secretario e gerente.
@WebServlet({"/login", "/logout"})
public class PainelLogin extends HttpServlet {

    private static final int HORAS_DE_SESSAO = 8;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String base = Painel.base(req);
        if ("/logout".equals(req.getServletPath())) {
            Painel.redirecionar(resp, base + "/login");
            return;
        }
        HttpSession sessao = req.getSession(false);
        boolean isLogado = sessao != null && sessao.getAttribute("usuario") != null;
        if (isLogado) {
            Painel.redirecionar(resp, base + "/painel");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/paginas/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String base = Painel.base(req);
        if ("/logout".equals(req.getServletPath())) {
            sair(req, resp, base);
            return;
        }
        Usuario usuario;
        try {
            usuario = Acesso.autenticar(req.getParameter("email"), req.getParameter("senha"));
        } catch (Exception e) {
            throw new ServletException(e);
        }
        if (usuario == null) {
            mostrarErro(req, resp, "E-mail ou senha incorretos.");
            return;
        }
        if (usuario.isCliente()) {
            mostrarErro(req, resp, "Clientes acessam pelo aplicativo, nao por este painel.");
            return;
        }
        // Sessao nova a cada login (evita reaproveitar uma sessao antiga).
        HttpSession antiga = req.getSession(false);
        if (antiga != null) {
            antiga.invalidate();
        }
        HttpSession sessao = req.getSession(true);
        sessao.setAttribute("usuario", usuario);
        sessao.setAttribute("csrf", Painel.sortearToken());
        sessao.setMaxInactiveInterval(HORAS_DE_SESSAO * 3600);
        Painel.redirecionar(resp, base + "/painel");
    }

    private void sair(HttpServletRequest req, HttpServletResponse resp, String base) throws IOException {
        HttpSession sessao = req.getSession(false);
        if (sessao != null) {
            String esperado = (String) sessao.getAttribute("csrf");
            String recebido = req.getParameter("csrf");
            if (esperado != null && esperado.equals(recebido)) {
                sessao.invalidate();
            }
        }
        Painel.redirecionar(resp, base + "/login");
    }

    private void mostrarErro(HttpServletRequest req, HttpServletResponse resp, String mensagem)
            throws ServletException, IOException {
        req.setAttribute("erro", mensagem);
        resp.setStatus(401);
        req.getRequestDispatcher("/WEB-INF/paginas/login.jsp").forward(req, resp);
    }
}
