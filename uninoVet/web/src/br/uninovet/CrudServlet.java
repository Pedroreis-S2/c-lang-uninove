package br.uninovet;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// Um unico servlet cuida do CRUD de todos os cadastros. A tabela vem no
// parametro "tabela" e a operacao no "acao". As telas ficam no crud.jsp.
@WebServlet("/crud")
public class CrudServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Tabela tabela = Tabela.por(req.getParameter("tabela"));
        if (tabela == null) {
            resp.sendRedirect("index.jsp");
            return;
        }
        try {
            if ("form".equals(req.getParameter("acao"))) {
                String id = req.getParameter("id");
                if (id != null && !id.isEmpty()) {
                    req.setAttribute("registro", Banco.buscar(tabela, Integer.parseInt(id)));
                    req.setAttribute("id", id);
                }
            } else {
                req.setAttribute("linhas", Banco.listar(tabela));
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
        req.setAttribute("tabela", tabela);
        req.getRequestDispatcher("/crud.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Tabela tabela = Tabela.por(req.getParameter("tabela"));
        try {
            if ("excluir".equals(req.getParameter("acao"))) {
                Banco.excluir(tabela, Integer.parseInt(req.getParameter("id")));
            } else {
                Map<String, String> dados = new LinkedHashMap<>();
                for (String campo : tabela.campos()) {
                    dados.put(campo, req.getParameter(campo));
                }
                String id = req.getParameter("id");
                if (id != null && !id.isEmpty()) {
                    Banco.atualizar(tabela, Integer.parseInt(id), dados);
                } else {
                    Banco.inserir(tabela, dados);
                }
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
        resp.sendRedirect("crud?tabela=" + tabela.nome());
    }
}
