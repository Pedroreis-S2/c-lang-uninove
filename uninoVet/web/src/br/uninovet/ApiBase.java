package br.uninovet;

import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// Base das rotas /api. Cuida dos erros em um lugar so: ErroNegocio vira o
// status certo; qualquer outra falha vira 500 sem vazar detalhe interno.
public abstract class ApiBase extends HttpServlet {

    // usuario vem do FiltroApi (null so nas rotas publicas: login e cadastro).
    protected abstract void executar(HttpServletRequest req, HttpServletResponse resp, Usuario usuario)
            throws Exception;

    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            executar(req, resp, Acesso.daRequisicao(req));
        } catch (ErroNegocio e) {
            Json.erro(resp, e.status, e.getMessage());
        } catch (Exception e) {
            System.out.println("[Api] erro em " + req.getMethod() + " " + req.getRequestURI() + ": " + e);
            e.printStackTrace();
            Json.erro(resp, 500, "Erro interno.");
        }
    }

    protected int inteiro(HttpServletRequest req, String nome) {
        String texto = req.getParameter(nome);
        try {
            return Integer.parseInt(texto.trim());
        } catch (Exception e) {
            throw ErroNegocio.invalido("Parametro invalido: " + nome);
        }
    }

    protected void metodoNaoPermitido(HttpServletResponse resp) throws IOException {
        Json.erro(resp, 405, "Metodo nao permitido.");
    }
}
