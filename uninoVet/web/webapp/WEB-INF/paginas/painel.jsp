<%@ page contentType="text/html; charset=UTF-8" %>
<% String titulo = "Painel"; %>
<%@ include file="topo.jsp" %>
<%
  List<Map<String, Object>> hoje = (List<Map<String, Object>>) request.getAttribute("hoje");
  List<Map<String, Object>> pendentes = (List<Map<String, Object>>) request.getAttribute("pendentes");
%>
    <h2>Olá, <%= Html.esc(usuario.nome) %></h2>
    <div class="resumo">
      <div class="numero"><strong><%= hoje.size() %></strong><span><%= usuario.isVeterinario() ? "consultas suas hoje" : "consultas hoje" %></span></div>
<% if (pendentes != null) { %>
      <a class="numero destaque" href="<%= base %>/solicitacoes"><strong><%= pendentes.size() %></strong><span>solicitações a responder</span></a>
<% } %>
    </div>

    <h3>Hoje</h3>
    <table>
      <thead><tr><th>Hora</th><th>Pet</th><th>Veterinário</th><th>Serviço</th><th>Status</th></tr></thead>
      <tbody>
<% if (hoje.isEmpty()) { %>
        <tr><td colspan="5" class="vazio">Nada marcado para hoje.</td></tr>
<% } %>
<% for (Map<String, Object> consulta : hoje) { %>
        <tr>
          <td><%= Html.dataHora(consulta.get("data_hora")).substring(11) %></td>
          <td><%= Html.esc(consulta.get("animal")) %> <small>(<%= Html.esc(consulta.get("tutor")) %>)</small></td>
          <td><%= Html.esc(consulta.get("veterinario")) %></td>
          <td><%= Html.esc(consulta.get("tipo_servico")) %></td>
          <td><span class="status <%= Html.esc(consulta.get("status")) %>"><%= Html.statusLegivel(consulta.get("status")) %></span></td>
        </tr>
<% } %>
      </tbody>
    </table>
<%@ include file="rodape.jsp" %>
