package br.uninovet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

// Telas do painel da clinica. Busca os dados, entrega para o JSP (que so
// desenha) e mostra a mensagem de aviso/erro da ultima acao.
@WebServlet({"/painel", "/agenda", "/solicitacoes", "/usuarios", "/admin", "/admin/"})
public class PaginaServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Usuario usuario = (Usuario) req.getAttribute("usuario");
        String caminho = req.getServletPath();
        try {
            moverAvisoDaSessao(req);
            if ("/painel".equals(caminho)) {
                prepararPainel(req, usuario);
            } else if ("/agenda".equals(caminho)) {
                prepararAgenda(req, usuario);
            } else if ("/solicitacoes".equals(caminho)) {
                exigirEquipe(usuario);
                req.setAttribute("solicitacoes", Consultas.listarPorStatus("SOLICITADA"));
            } else if ("/usuarios".equals(caminho)) {
                exigirGerente(usuario);
                req.setAttribute("usuarios", listarUsuarios());
            }
        } catch (ErroNegocio e) {
            resp.sendError(e.status, e.getMessage());
            return;
        } catch (Exception e) {
            throw new ServletException(e);
        }
        String pagina = caminho.startsWith("/admin") ? "admin_index" : caminho.substring(1);
        req.getRequestDispatcher("/WEB-INF/paginas/" + pagina + ".jsp").forward(req, resp);
    }

    private void prepararPainel(HttpServletRequest req, Usuario usuario) throws Exception {
        String hoje = Agenda.agora().toLocalDate().toString();
        Integer veterinarioId = usuario.isVeterinario() ? usuario.veterinarioId : null;
        req.setAttribute("hoje", Consultas.listarDoDia(hoje, veterinarioId));
        if (usuario.isEquipeDeAgenda()) {
            req.setAttribute("pendentes", Consultas.listarPorStatus("SOLICITADA"));
        }
    }

    private void prepararAgenda(HttpServletRequest req, Usuario usuario) throws Exception {
        LocalDate dia = Agenda.agora().toLocalDate();
        String diaPedido = req.getParameter("dia");
        if (diaPedido != null && !diaPedido.isEmpty()) {
            dia = Agenda.lerDia(diaPedido);
        }
        Integer veterinarioId = null;
        if (usuario.isVeterinario()) {
            veterinarioId = usuario.veterinarioId;
        } else if (req.getParameter("veterinario_id") != null && !req.getParameter("veterinario_id").isEmpty()) {
            veterinarioId = Integer.parseInt(req.getParameter("veterinario_id"));
        }
        List<Map<String, Object>> consultas = Consultas.listarDoDia(dia.toString(), veterinarioId);
        req.setAttribute("dia", dia.toString());
        req.setAttribute("veterinarioFiltro", veterinarioId);
        req.setAttribute("consultas", consultas);

        Map<Object, List<Map<String, Object>>> documentos = new LinkedHashMap<>();
        for (Map<String, Object> consulta : consultas) {
            Object total = consulta.get("total_documentos");
            boolean isComDocumento = total instanceof Integer && ((Integer) total) > 0;
            if (isComDocumento) {
                Integer consultaId = (Integer) consulta.get("id");
                documentos.put(consultaId, Documentos.listar(usuario, consultaId));
            }
        }
        req.setAttribute("documentos", documentos);

        if (usuario.isEquipeDeAgenda()) {
            req.setAttribute("veterinarios", Banco.listar(Tabela.por("veterinario")));
            req.setAttribute("servicos", Banco.listar(Tabela.por("tipo_servico")));
            req.setAttribute("animais", Banco.listar(Tabela.por("animal")));
        }
    }

    private List<Map<String, Object>> listarUsuarios() throws Exception {
        try (Connection conexao = Banco.abrir()) {
            PreparedStatement comando = conexao.prepareStatement(
                    "SELECT id, nome, email, perfil, ativo FROM usuario ORDER BY perfil, nome");
            return Json.linhas(comando.executeQuery());
        }
    }

    // A mensagem da acao anterior (guardada na sessao) aparece uma vez so.
    private void moverAvisoDaSessao(HttpServletRequest req) {
        HttpSession sessao = req.getSession(false);
        if (sessao == null) {
            return;
        }
        req.setAttribute("aviso", sessao.getAttribute("aviso"));
        req.setAttribute("erro", sessao.getAttribute("erro"));
        sessao.removeAttribute("aviso");
        sessao.removeAttribute("erro");
    }

    private void exigirEquipe(Usuario usuario) {
        if (!usuario.isEquipeDeAgenda()) {
            throw ErroNegocio.proibido("Somente secretario ou gerente acessam esta tela.");
        }
    }

    private void exigirGerente(Usuario usuario) {
        if (!usuario.isGerente()) {
            throw ErroNegocio.proibido("Somente o gerente acessa esta tela.");
        }
    }
}
