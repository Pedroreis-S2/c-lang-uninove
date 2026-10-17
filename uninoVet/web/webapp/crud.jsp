<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="br.uninovet.Tabela, java.util.List, java.util.Map" %>
<%
  Tabela tabela = (Tabela) request.getAttribute("tabela");
  List<Map<String, String>> linhas = (List<Map<String, String>>) request.getAttribute("linhas");
  Map<String, String> registro = (Map<String, String>) request.getAttribute("registro");
  String id = (String) request.getAttribute("id");
  boolean form = "form".equals(request.getParameter("acao"));
%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>UninoVet - <%= tabela.titulo() %></title>
  <link rel="stylesheet" href="estilo.css">
</head>
<body>
  <header>
    <h1>UninoVet</h1>
    <p><a href="index.jsp">Painel</a> / <%= tabela.titulo() %></p>
  </header>
  <main>
<% if (form) { %>
    <h2><%= id != null ? "Editar" : "Novo" %> &middot; <%= tabela.titulo() %></h2>
    <form method="post" action="crud" class="formulario">
      <input type="hidden" name="tabela" value="<%= tabela.nome() %>">
<% if (id != null) { %>
      <input type="hidden" name="id" value="<%= id %>">
<% } %>
<% for (String campo : tabela.campos()) {
     String valor = registro != null && registro.get(campo) != null ? registro.get(campo) : ""; %>
      <label><%= campo %>
        <input name="<%= campo %>" value="<%= valor %>" required>
      </label>
<% } %>
      <div class="acoes">
        <button type="submit">Salvar</button>
        <a class="botao claro" href="crud?tabela=<%= tabela.nome() %>">Cancelar</a>
      </div>
    </form>
<% } else { %>
    <div class="topo">
      <h2><%= tabela.titulo() %></h2>
      <a class="botao" href="crud?tabela=<%= tabela.nome() %>&acao=form">+ Novo</a>
    </div>
    <table>
      <thead>
        <tr>
<% for (String coluna : linhas.isEmpty() ? tabela.campos() : linhas.get(0).keySet()) { %>
          <th><%= coluna %></th>
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
          <td><%= valor == null ? "" : valor %></td>
<% } %>
          <td class="acoes">
            <a href="crud?tabela=<%= tabela.nome() %>&acao=form&id=<%= linha.get("id") %>">Editar</a>
            <form method="post" action="crud" onsubmit="return confirm('Excluir este registro?')">
              <input type="hidden" name="tabela" value="<%= tabela.nome() %>">
              <input type="hidden" name="acao" value="excluir">
              <input type="hidden" name="id" value="<%= linha.get("id") %>">
              <button type="submit" class="link">Excluir</button>
            </form>
          </td>
        </tr>
<% } %>
      </tbody>
    </table>
<% } %>
  </main>
</body>
</html>
