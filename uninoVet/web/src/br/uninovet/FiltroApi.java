package br.uninovet;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// Porta de entrada da API: cuida do CORS e exige o token em tudo, menos em
// /api/login e /api/cadastro. Os servlets recebem o usuario ja validado.
@WebFilter("/api/*")
public class FiltroApi implements Filter {

    @Override
    public void doFilter(ServletRequest requisicao, ServletResponse resposta, FilterChain cadeia)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) requisicao;
        HttpServletResponse resp = (HttpServletResponse) resposta;

        // Atras do proxy (mesma origem) o CORS nem e usado. Em producao defina
        // CORS_ORIGEM com o endereco do app.
        String origemPermitida = System.getenv().getOrDefault("CORS_ORIGEM", "*");
        resp.setHeader("Access-Control-Allow-Origin", origemPermitida);
        resp.setHeader("Access-Control-Allow-Headers", "Authorization, Content-Type");
        resp.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        if ("OPTIONS".equals(req.getMethod())) {
            resp.setStatus(204);
            return;
        }

        String caminho = req.getServletPath();
        String caminhoCompleto = caminho + (req.getPathInfo() == null ? "" : req.getPathInfo());
        boolean isLinkTemporario = caminhoCompleto.matches("/api/documentos/\\d+/arquivo");
        boolean isRotaPublica = "/api/login".equals(caminho) || "/api/cadastro".equals(caminho) || isLinkTemporario;
        if (isRotaPublica) {
            cadeia.doFilter(requisicao, resposta);
            return;
        }

        try {
            Usuario usuario = Acesso.porToken(Acesso.tokenDaRequisicao(req));
            if (usuario == null) {
                Json.erro(resp, 401, "Entre novamente: sessao invalida ou expirada.");
                return;
            }
            req.setAttribute("usuario", usuario);
        } catch (Exception e) {
            Json.erro(resp, 500, "Erro interno.");
            return;
        }
        cadeia.doFilter(requisicao, resposta);
    }
}
