<%@ page contentType="text/html; charset=UTF-8" %>
<% String titulo = "Admin"; %>
<%@ include file="topo.jsp" %>
    <h2>Administração do banco</h2>
    <p class="dica">Acesso direto aos cadastros (somente gerente). Para o dia a dia use Agenda e Solicitações.</p>
    <ul class="menu">
<%
      for (Map.Entry<String, Tabela> item : Tabela.todas().entrySet()) {
%>
      <li><a href="<%= base %>/admin/crud?tabela=<%= Html.esc(item.getKey()) %>"><%= Html.esc(item.getValue().titulo()) %></a></li>
<%
      }
%>
    </ul>
<%
      String urlApp = System.getenv("APP_URL");
      if (urlApp != null && !urlApp.isEmpty()) {
%>
    <p><a class="botao" href="<%= Html.esc(urlApp) %>" target="_blank" rel="noopener">Abrir o aplicativo do cliente</a></p>
<%
      }
%>
<%@ include file="rodape.jsp" %>
