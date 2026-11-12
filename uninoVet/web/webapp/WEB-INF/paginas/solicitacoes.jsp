<%@ page contentType="text/html; charset=UTF-8" %>
<% String titulo = "Solicitações"; %>
<%@ include file="topo.jsp" %>
<%
  List<Map<String, Object>> solicitacoes = (List<Map<String, Object>>) request.getAttribute("solicitacoes");
%>
    <h2>Solicitações de clientes</h2>
    <p class="dica">Aceitar reserva o horário do veterinário. Se alguém já ocupou o horário, o sistema avisa e você recusa ou pede para o cliente solicitar de novo.</p>
    <table>
      <thead><tr><th>Quando</th><th>Pet / Tutor</th><th>Veterinário</th><th>Serviço</th><th>Motivo</th><th>Ações</th></tr></thead>
      <tbody>
<% if (solicitacoes.isEmpty()) { %>
        <tr><td colspan="6" class="vazio">Nenhuma solicitação pendente.</td></tr>
<% } %>
<% for (Map<String, Object> solicitacao : solicitacoes) { %>
        <tr>
          <td><%= Html.dataHora(solicitacao.get("data_hora")) %></td>
          <td><%= Html.esc(solicitacao.get("animal")) %> <small>(<%= Html.esc(solicitacao.get("tutor")) %>)</small></td>
          <td><%= Html.esc(solicitacao.get("veterinario")) %></td>
          <td><%= Html.esc(solicitacao.get("tipo_servico")) %></td>
          <td><%= Html.esc(solicitacao.get("motivo")) %></td>
          <td>
            <form method="post" action="<%= base %>/acoes" class="linha">
              <input type="hidden" name="csrf" value="<%= csrf %>">
              <input type="hidden" name="voltar" value="/solicitacoes">
              <input type="hidden" name="id" value="<%= solicitacao.get("id") %>">
              <button type="submit" name="acao" value="aceitar">Aceitar</button>
            </form>
            <form method="post" action="<%= base %>/acoes" class="linha">
              <input type="hidden" name="csrf" value="<%= csrf %>">
              <input type="hidden" name="voltar" value="/solicitacoes">
              <input type="hidden" name="id" value="<%= solicitacao.get("id") %>">
              <input name="motivo" placeholder="Motivo (opcional)" maxlength="160">
              <button type="submit" name="acao" value="recusar" class="link">Recusar</button>
            </form>
          </td>
        </tr>
<% } %>
      </tbody>
    </table>
<%@ include file="rodape.jsp" %>
