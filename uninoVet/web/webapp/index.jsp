<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="br.uninovet.Tabela, java.util.Map" %>
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>UninoVet - Painel</title>
  <link rel="stylesheet" href="estilo.css">
</head>
<body>
  <header>
    <h1>UninoVet</h1>
    <p>Painel administrativo da clínica</p>
  </header>
  <main>
    <h2>Cadastros</h2>
    <ul class="menu">
<%
      for (Map.Entry<String, Tabela> item : Tabela.todas().entrySet()) {
%>
      <li><a href="crud?tabela=<%= item.getKey() %>"><%= item.getValue().titulo() %></a></li>
<%
      }
%>
    </ul>
  </main>
</body>
</html>
