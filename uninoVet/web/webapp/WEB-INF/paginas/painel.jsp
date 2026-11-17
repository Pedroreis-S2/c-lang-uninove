<%@ page contentType="text/html; charset=UTF-8" %>
<% String titulo = "Painel"; %>
<%@ include file="topo.jsp" %>
<%
  List<Map<String, Object>> hoje = (List<Map<String, Object>>) request.getAttribute("hoje");
  List<Map<String, Object>> pendentes = (List<Map<String, Object>>) request.getAttribute("pendentes");
  String primeiroNome = usuario.nome == null ? "" : usuario.nome.split(" ")[0];
%>
    <div class="topo">
      <div>
        <h2>Olá, <%= Html.esc(primeiroNome) %> 👋</h2>
        <p>Veja o que está acontecendo na clínica hoje.</p>
      </div>
      <a class="botao claro" href="<%= base %>/agenda"><%= Icones.svg("agenda") %> Abrir agenda</a>
    </div>

    <div class="resumo">
      <div class="numero">
        <span class="icone-caixa"><%= Icones.svg("agenda") %></span>
        <strong><%= hoje.size() %></strong>
        <span><%= usuario.isVeterinario() ? "consultas suas hoje" : "consultas hoje" %></span>
      </div>
<% if (pendentes != null) { %>
      <a class="numero destaque" href="<%= base %>/solicitacoes">
        <span class="icone-caixa"><%= Icones.svg("solicitacoes") %></span>
        <strong><%= pendentes.size() %></strong>
        <span>solicitações a responder</span>
      </a>
<% } %>
    </div>

    <h3>Consultas de hoje</h3>
    <div class="tabela-wrap">
    <table>
      <thead><tr><th>Hora</th><th>Pet</th><th>Veterinário</th><th>Serviço</th><th>Status</th></tr></thead>
      <tbody>
<% if (hoje.isEmpty()) { %>
        <tr><td colspan="5" class="vazio">Nada marcado para hoje.</td></tr>
<% } %>
<% for (Map<String, Object> consulta : hoje) { %>
        <tr>
          <td class="hora"><%= Html.dataHora(consulta.get("data_hora")).substring(11) %></td>
          <td><span class="pet"><%= Html.esc(consulta.get("animal")) %></span> <small>Tutor: <%= Html.esc(consulta.get("tutor")) %></small></td>
          <td><%= Html.esc(consulta.get("veterinario")) %></td>
          <td><%= Html.esc(consulta.get("tipo_servico")) %></td>
          <td><span class="status <%= Html.esc(consulta.get("status")) %>"><%= Html.statusLegivel(consulta.get("status")) %></span></td>
        </tr>
<% } %>
      </tbody>
    </table>
    </div>
<%@ include file="rodape.jsp" %>
