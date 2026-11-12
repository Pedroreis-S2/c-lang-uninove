package br.uninovet;

import java.io.IOException;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;

// JSON escrito a mao (o projeto nao usa biblioteca). O back devolve dado cru;
// formatacao e label ficam no app.
public class Json {

    public static String texto(String valor) {
        StringBuilder saida = new StringBuilder("\"");
        for (int i = 0; i < valor.length(); i++) {
            char letra = valor.charAt(i);
            if (letra == '\\') {
                saida.append("\\\\");
            } else if (letra == '"') {
                saida.append("\\\"");
            } else if (letra == '\n') {
                saida.append("\\n");
            } else if (letra == '\r') {
                saida.append("\\r");
            } else if (letra == '\t') {
                saida.append("\\t");
            } else if (letra < 0x20) {
                saida.append(String.format("\\u%04x", (int) letra));
            } else {
                saida.append(letra);
            }
        }
        saida.append("\"");
        return saida.toString();
    }

    @SuppressWarnings("unchecked")
    public static String valor(Object objeto) {
        if (objeto == null) {
            return "null";
        }
        if (objeto instanceof Number || objeto instanceof Boolean) {
            return objeto.toString();
        }
        if (objeto instanceof List) {
            StringBuilder lista = new StringBuilder("[");
            boolean primeiro = true;
            for (Object item : (List<Object>) objeto) {
                if (!primeiro) {
                    lista.append(",");
                }
                primeiro = false;
                lista.append(valor(item));
            }
            lista.append("]");
            return lista.toString();
        }
        if (objeto instanceof Map) {
            StringBuilder mapa = new StringBuilder("{");
            boolean primeiro = true;
            for (Map.Entry<String, Object> campo : ((Map<String, Object>) objeto).entrySet()) {
                if (!primeiro) {
                    mapa.append(",");
                }
                primeiro = false;
                mapa.append(texto(campo.getKey())).append(":").append(valor(campo.getValue()));
            }
            mapa.append("}");
            return mapa.toString();
        }
        return texto(objeto.toString());
    }

    // Converte o resultado de uma consulta em lista de mapas (inteiros viram numero).
    public static List<Map<String, Object>> linhas(ResultSet resultado) throws SQLException {
        List<Map<String, Object>> linhas = new ArrayList<>();
        ResultSetMetaData meta = resultado.getMetaData();
        while (resultado.next()) {
            Map<String, Object> linha = new LinkedHashMap<>();
            for (int i = 1; i <= meta.getColumnCount(); i++) {
                int tipo = meta.getColumnType(i);
                boolean isNumero = tipo == Types.INTEGER || tipo == Types.BIGINT
                        || tipo == Types.SMALLINT || tipo == Types.TINYINT || tipo == Types.BIT;
                if (isNumero) {
                    int numero = resultado.getInt(i);
                    boolean isNulo = resultado.wasNull();
                    linha.put(meta.getColumnLabel(i), isNulo ? null : numero);
                } else {
                    linha.put(meta.getColumnLabel(i), resultado.getString(i));
                }
            }
            linhas.add(linha);
        }
        return linhas;
    }

    public static void responder(HttpServletResponse resp, int status, Object conteudo) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().print(valor(conteudo));
    }

    // Resposta de sucesso: {"data": ...}
    public static void dados(HttpServletResponse resp, int status, Object conteudo) throws IOException {
        Map<String, Object> corpo = new LinkedHashMap<>();
        corpo.put("data", conteudo);
        responder(resp, status, corpo);
    }

    // Resposta de erro: {"erro": "mensagem"}
    public static void erro(HttpServletResponse resp, int status, String mensagem) throws IOException {
        Map<String, Object> corpo = new LinkedHashMap<>();
        corpo.put("erro", mensagem);
        responder(resp, status, corpo);
    }
}
