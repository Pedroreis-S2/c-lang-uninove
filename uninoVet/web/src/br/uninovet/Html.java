package br.uninovet;

// Ajudantes das paginas JSP. Todo dado do banco impresso na pagina passa por
// esc(), para um texto malicioso nao virar codigo na tela (XSS).
public class Html {

    public static String esc(Object valor) {
        if (valor == null) {
            return "";
        }
        String texto = valor.toString();
        StringBuilder saida = new StringBuilder();
        for (int i = 0; i < texto.length(); i++) {
            char letra = texto.charAt(i);
            if (letra == '&') {
                saida.append("&amp;");
            } else if (letra == '<') {
                saida.append("&lt;");
            } else if (letra == '>') {
                saida.append("&gt;");
            } else if (letra == '"') {
                saida.append("&quot;");
            } else if (letra == '\'') {
                saida.append("&#39;");
            } else {
                saida.append(letra);
            }
        }
        return saida.toString();
    }

    // "2026-12-01 13:00:00" -> "01/12/2026 13:00"
    public static String dataHora(Object valor) {
        if (valor == null) {
            return "";
        }
        String texto = valor.toString();
        if (texto.length() < 16) {
            return esc(texto);
        }
        String ano = texto.substring(0, 4);
        String mes = texto.substring(5, 7);
        String dia = texto.substring(8, 10);
        String hora = texto.substring(11, 16);
        return esc(dia + "/" + mes + "/" + ano + " " + hora);
    }

    public static String statusLegivel(Object status) {
        String texto = status == null ? "" : status.toString();
        if ("SOLICITADA".equals(texto)) {
            return "Solicitada";
        }
        if ("AGENDADA".equals(texto)) {
            return "Agendada";
        }
        if ("RECUSADA".equals(texto)) {
            return "Recusada";
        }
        if ("CONCLUIDA".equals(texto)) {
            return "Concluída";
        }
        if ("CANCELADA".equals(texto)) {
            return "Cancelada";
        }
        return esc(texto);
    }
}
