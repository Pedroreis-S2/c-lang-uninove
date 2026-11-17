<%@ page contentType="text/html; charset=UTF-8" %>
<% String titulo = "Admin"; %>
<%@ include file="topo.jsp" %>
    <div class="topo">
      <div>
        <h2>Administração do banco</h2>
        <p>Acesso direto aos cadastros (somente gerente).</p>
      </div>
<%
      String urlApp = System.getenv("APP_URL");
      if (urlApp != null && !urlApp.isEmpty()) {
%>
      <a class="botao claro" href="<%= Html.esc(urlApp) %>" target="_blank" rel="noopener"><%= Icones.svg("celular") %> Abrir o app do cliente</a>
<%
      }
%>
    </div>
    <p class="dica">Para o dia a dia use Agenda e Solicitações. Aqui você edita os registros diretamente; exclusões não podem ser desfeitas.</p>
    <ul class="grade-tabelas">
<%
      for (Map.Entry<String, Tabela> item : Tabela.todas().entrySet()) {
%>
      <li><a href="<%= base %>/admin/crud?tabela=<%= Html.esc(item.getKey()) %>"><span class="icone-caixa"><%= Icones.svg("banco") %></span><%= Html.esc(item.getValue().titulo()) %></a></li>
<%
      }
%>
    </ul>
<%@ include file="rodape.jsp" %>
