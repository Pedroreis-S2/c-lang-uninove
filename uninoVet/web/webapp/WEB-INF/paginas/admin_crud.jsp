<%@ page contentType="text/html; charset=UTF-8" %>
<%
  Tabela tabela = (Tabela) request.getAttribute("tabela");
  List<Map<String, String>> linhas = (List<Map<String, String>>) request.getAttribute("linhas");
  Map<String, String> registro = (Map<String, String>) request.getAttribute("registro");
  String id = (String) request.getAttribute("id");
  boolean form = "form".equals(request.getParameter("acao"));
  String titulo = tabela.titulo();
%>
<%@ include file="topo.jsp" %>
<% if (form) { %>
    <h2><%= id != null ? "Editar" : "Novo" %> &middot; <%= Html.esc(tabela.titulo()) %></h2>
    <form method="post" action="<%= base %>/admin/crud" class="formulario">
      <input type="hidden" name="csrf" value="<%= csrf %>">
      <input type="hidden" name="tabela" value="<%= Html.esc(tabela.nome()) %>">
<% if (id != null) { %>
      <input type="hidden" name="id" value="<%= Html.esc(id) %>">
<% } %>
<% for (String campo : tabela.campos()) {
     String valor = registro != null && registro.get(campo) != null ? registro.get(campo) : ""; %>
      <label><%= Html.esc(campo) %>
        <input name="<%= Html.esc(campo) %>" value="<%= Html.esc(valor) %>">
      </label>
<% } %>
      <div class="acoes">
        <button type="submit">Salvar</button>
        <a class="botao claro" href="<%= base %>/admin/crud?tabela=<%= Html.esc(tabela.nome()) %>">Cancelar</a>
      </div>
    </form>
<% } else { %>
    <div class="topo">
      <h2><%= Html.esc(tabela.titulo()) %></h2>
      <a class="botao" href="<%= base %>/admin/crud?tabela=<%= Html.esc(tabela.nome()) %>&acao=form">+ Novo</a>
    </div>
    <table>
      <thead>
        <tr>
<% for (String coluna : linhas.isEmpty() ? tabela.campos() : linhas.get(0).keySet()) { %>
          <th><%= Html.esc(coluna) %></th>
<% } %>
          <th>Ações</th>
        </tr>
      </thead>
      <tbody>
<% if (linhas.isEmpty()) { %>
        <tr><td colspan="99" class="vazio">Nenhum registro.</td></tr>
<% } %>
<% for (Map<String, String> linha : linhas) { %>
        <tr>
<% for (String valor : linha.values()) { %>
          <td><%= Html.esc(valor) %></td>
<% } %>
          <td class="acoes">
            <a href="<%= base %>/admin/crud?tabela=<%= Html.esc(tabela.nome()) %>&acao=form&id=<%= Html.esc(linha.get("id")) %>">Editar</a>
            <form method="post" action="<%= base %>/admin/crud" onsubmit="return confirm('Excluir este registro?')">
              <input type="hidden" name="csrf" value="<%= csrf %>">
              <input type="hidden" name="tabela" value="<%= Html.esc(tabela.nome()) %>">
              <input type="hidden" name="acao" value="excluir">
              <input type="hidden" name="id" value="<%= Html.esc(linha.get("id")) %>">
              <button type="submit" class="link">Excluir</button>
            </form>
          </td>
        </tr>
<% } %>
      </tbody>
    </table>
<% } %>
<%@ include file="rodape.jsp" %>
