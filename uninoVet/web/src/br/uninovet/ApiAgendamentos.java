package br.uninovet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// Lista os agendamentos em JSON para o aplicativo Flutter consumir.
@WebServlet("/api/agendamentos")
public class ApiAgendamentos extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        resp.setHeader("Access-Control-Allow-Origin", "*");
        String sql = "SELECT c.id, a.nome AS animal, a.especie, v.nome AS veterinario, "
                + "c.data_hora, c.motivo, c.status FROM consulta c "
                + "JOIN animal a ON a.id = c.animal_id "
                + "JOIN veterinario v ON v.id = c.veterinario_id ORDER BY c.data_hora";
        PrintWriter saida = resp.getWriter();
        try {
            Connection conexao = Banco.abrir();
            PreparedStatement comando = conexao.prepareStatement(sql);
            ResultSet resultado = comando.executeQuery();
            StringBuilder json = new StringBuilder("[");
            boolean primeiro = true;
            while (resultado.next()) {
                if (!primeiro) {
                    json.append(",");
                }
                primeiro = false;
                json.append("{")
                        .append(numero("id", resultado.getString("id"))).append(",")
                        .append(texto("animal", resultado.getString("animal"))).append(",")
                        .append(texto("especie", resultado.getString("especie"))).append(",")
                        .append(texto("veterinario", resultado.getString("veterinario"))).append(",")
                        .append(texto("data_hora", resultado.getString("data_hora"))).append(",")
                        .append(texto("motivo", resultado.getString("motivo"))).append(",")
                        .append(texto("status", resultado.getString("status")))
                        .append("}");
            }
            json.append("]");
            conexao.close();
            saida.print(json);
        } catch (Exception e) {
            resp.setStatus(500);
            saida.print("{\"erro\":\"" + e.getMessage() + "\"}");
        }
    }

    private String texto(String chave, String valor) {
        String conteudo = valor == null ? "" : valor.replace("\\", "\\\\").replace("\"", "\\\"");
        return "\"" + chave + "\":\"" + conteudo + "\"";
    }

    private String numero(String chave, String valor) {
        return "\"" + chave + "\":" + (valor == null ? "null" : valor);
    }
}
