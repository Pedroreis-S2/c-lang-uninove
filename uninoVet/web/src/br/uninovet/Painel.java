package br.uninovet;

import java.security.SecureRandom;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// Ajudantes do painel da clinica.
public class Painel {

    // Atras do proxy o painel fica em /clinica; o nginx avisa pelo cabecalho
    // X-Forwarded-Prefix. Direto na porta 8080 o prefixo e vazio.
    public static String base(HttpServletRequest req) {
        String prefixo = req.getHeader("X-Forwarded-Prefix");
        if (prefixo == null || !prefixo.matches("/[A-Za-z0-9_-]+")) {
            return "";
        }
        return prefixo;
    }

    // Redireciona so com o caminho (sem scheme e host). Atras do proxy HTTPS do
    // Codespace, o Tomcat montaria http://... e o navegador bloquearia.
    public static void redirecionar(HttpServletResponse resp, String caminho) {
        resp.setStatus(302);
        resp.setHeader("Location", caminho);
    }

    public static String sortearToken() {
        byte[] bytes = new byte[24];
        SecureRandom sorteio = new SecureRandom();
        sorteio.nextBytes(bytes);
        StringBuilder token = new StringBuilder();
        for (byte parte : bytes) {
            token.append(String.format("%02x", parte));
        }
        return token.toString();
    }

    // So aceita voltar para paginas do proprio painel (evita redirecionar para fora).
    public static String destinoSeguro(String pedido, String padrao) {
        boolean isSeguro = pedido != null && pedido.matches("/(painel|agenda|solicitacoes|usuarios)(\\?[A-Za-z0-9_=&-]*)?");
        return isSeguro ? pedido : padrao;
    }
}
