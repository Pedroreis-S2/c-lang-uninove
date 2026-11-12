<%@ page contentType="text/html; charset=UTF-8" %>
<% String titulo = "Agenda"; %>
<%@ include file="topo.jsp" %>
<%
  String dia = (String) request.getAttribute("dia");
  Integer veterinarioFiltro = (Integer) request.getAttribute("veterinarioFiltro");
  List<Map<String, Object>> consultas = (List<Map<String, Object>>) request.getAttribute("consultas");
  Map<Object, List<Map<String, Object>>> documentos = (Map<Object, List<Map<String, Object>>>) request.getAttribute("documentos");
  List<Map<String, String>> veterinarios = (List<Map<String, String>>) request.getAttribute("veterinarios");
  List<Map<String, String>> servicos = (List<Map<String, String>>) request.getAttribute("servicos");
  List<Map<String, String>> animais = (List<Map<String, String>>) request.getAttribute("animais");
  String voltar = "/agenda?dia=" + dia;
%>
    <div class="topo">
      <h2>Agenda</h2>
    </div>
    <form method="get" action="<%= base %>/agenda" class="filtro">
      <label>Dia <input type="date" name="dia" value="<%= Html.esc(dia) %>"></label>
<% if (veterinarios != null) { %>
      <label>Veterinário
        <select name="veterinario_id">
          <option value="">Todos</option>
<% for (Map<String, String> veterinario : veterinarios) {
     boolean isEscolhido = veterinarioFiltro != null && String.valueOf(veterinarioFiltro).equals(veterinario.get("id")); %>
          <option value="<%= Html.esc(veterinario.get("id")) %>" <%= isEscolhido ? "selected" : "" %>><%= Html.esc(veterinario.get("nome")) %></option>
<% } %>
        </select>
      </label>
<% } %>
      <button type="submit">Ver</button>
    </form>

    <table>
      <thead><tr><th>Horário</th><th>Pet / Tutor</th><th>Veterinário</th><th>Serviço</th><th>Status</th><th>Ações</th></tr></thead>
      <tbody>
<% if (consultas.isEmpty()) { %>
        <tr><td colspan="6" class="vazio">Nada marcado neste dia.</td></tr>
<% } %>
<% for (Map<String, Object> consulta : consultas) {
     String status = (String) consulta.get("status");
     boolean isAtiva = "SOLICITADA".equals(status) || "AGENDADA".equals(status);
     Object consultaId = consulta.get("id");
     String fim = consulta.get("fim") == null ? "" : Html.dataHora(consulta.get("fim")).substring(11); %>
        <tr>
          <td><%= Html.dataHora(consulta.get("data_hora")).substring(11) %><% if (!fim.isEmpty()) { %> &ndash; <%= fim %><% } %></td>
          <td><%= Html.esc(consulta.get("animal")) %> <small>(<%= Html.esc(consulta.get("tutor")) %>)</small><br><small><%= Html.esc(consulta.get("motivo")) %></small></td>
          <td><%= Html.esc(consulta.get("veterinario")) %></td>
          <td><%= Html.esc(consulta.get("tipo_servico")) %></td>
          <td><span class="status <%= Html.esc(status) %>"><%= Html.statusLegivel(status) %></span>
<% if (consulta.get("motivo_recusa") != null) { %><br><small><%= Html.esc(consulta.get("motivo_recusa")) %></small><% } %></td>
          <td>
<% if (usuario.isEquipeDeAgenda() && "SOLICITADA".equals(status)) { %>
            <form method="post" action="<%= base %>/acoes" class="linha">
              <input type="hidden" name="csrf" value="<%= csrf %>">
              <input type="hidden" name="voltar" value="<%= Html.esc(voltar) %>">
              <input type="hidden" name="id" value="<%= consultaId %>">
              <button type="submit" name="acao" value="aceitar">Aceitar</button>
            </form>
<% } %>
<% if (usuario.isVeterinario() && "AGENDADA".equals(status)) { %>
            <form method="post" action="<%= base %>/acoes" class="linha">
              <input type="hidden" name="csrf" value="<%= csrf %>">
              <input type="hidden" name="voltar" value="<%= Html.esc(voltar) %>">
              <input type="hidden" name="id" value="<%= consultaId %>">
              <button type="submit" name="acao" value="concluir">Concluir</button>
            </form>
<% } %>
<% if (isAtiva && (usuario.isEquipeDeAgenda() || usuario.isVeterinario())) { %>
            <form method="post" action="<%= base %>/acoes" class="linha" onsubmit="return confirm('Cancelar esta consulta?')">
              <input type="hidden" name="csrf" value="<%= csrf %>">
              <input type="hidden" name="voltar" value="<%= Html.esc(voltar) %>">
              <input type="hidden" name="id" value="<%= consultaId %>">
              <button type="submit" name="acao" value="cancelar" class="link">Cancelar</button>
            </form>
<% } %>
<% List<Map<String, Object>> anexos = documentos.get(consultaId);
   if (anexos != null) {
     for (Map<String, Object> anexo : anexos) { %>
            <div><a href="<%= base %>/documentos/baixar?id=<%= anexo.get("id") %>"><%= Html.esc(anexo.get("tipo")) %>: <%= Html.esc(anexo.get("nome_arquivo")) %></a></div>
<%   }
   } %>
<% if (usuario.isVeterinario() && !"SOLICITADA".equals(status) && !"RECUSADA".equals(status)) { %>
            <form method="post" action="<%= base %>/documentos/enviar?csrf=<%= csrf %>" enctype="multipart/form-data" class="linha">
              <input type="hidden" name="voltar" value="<%= Html.esc(voltar) %>">
              <input type="hidden" name="consulta_id" value="<%= consultaId %>">
              <select name="tipo"><option value="RECEITA">Receita</option><option value="LAUDO">Laudo</option><option value="OUTRO">Outro</option></select>
              <input type="file" name="arquivo" accept=".pdf,.jpg,.jpeg,.png" required>
              <button type="submit">Anexar</button>
            </form>
<% } %>
          </td>
        </tr>
<% } %>
      </tbody>
    </table>

<% if (usuario.isEquipeDeAgenda()) { %>
    <h3>Novo agendamento (cliente que ligou)</h3>
    <form method="post" action="<%= base %>/acoes" class="formulario largo">
      <input type="hidden" name="csrf" value="<%= csrf %>">
      <input type="hidden" name="acao" value="agendar">
      <input type="hidden" name="voltar" value="<%= Html.esc(voltar) %>">
      <label>Pet
        <select name="animal_id" required>
<% for (Map<String, String> animal : animais) { %>
          <option value="<%= Html.esc(animal.get("id")) %>"><%= Html.esc(animal.get("nome")) %> (<%= Html.esc(animal.get("especie")) %>)</option>
<% } %>
        </select>
      </label>
      <label>Veterinário
        <select name="veterinario_id" required>
<% for (Map<String, String> veterinario : veterinarios) { %>
          <option value="<%= Html.esc(veterinario.get("id")) %>"><%= Html.esc(veterinario.get("nome")) %></option>
<% } %>
        </select>
      </label>
      <label>Serviço
        <select name="tipo_servico_id" required>
<% for (Map<String, String> servico : servicos) { %>
          <option value="<%= Html.esc(servico.get("id")) %>"><%= Html.esc(servico.get("nome")) %> (<%= Html.esc(servico.get("duracao_minutos")) %> min)</option>
<% } %>
        </select>
      </label>
      <label>Data e hora <input type="datetime-local" name="data_hora" step="1800" required></label>
      <label>Motivo <input name="motivo" maxlength="160" required></label>
      <button type="submit">Agendar</button>
    </form>
<% } %>
<%@ include file="rodape.jsp" %>
