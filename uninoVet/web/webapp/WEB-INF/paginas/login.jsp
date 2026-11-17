<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="br.uninovet.Html, br.uninovet.Icones" %>
<%
  String base = (String) request.getAttribute("base");
  String erro = (String) request.getAttribute("erro");
%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>UninoVet - Entrar</title>
  <link rel="stylesheet" href="<%= base %>/estilo.css">
</head>
<body class="entrada">
  <main class="cartao-login">
    <div class="logo"><%= Icones.svg("logo") %></div>
    <h1>UninoVet</h1>
    <p>Painel da clínica: veterinários, secretaria e gerência.</p>
<% if (erro != null) { %>
    <p class="aviso erro" role="alert"><%= Html.esc(erro) %></p>
<% } %>
    <form method="post" action="<%= base %>/login" class="formulario">
      <label>E-mail
        <input type="email" name="email" placeholder="voce@uninovet.com" autocomplete="username" required autofocus>
      </label>
      <label>Senha
        <input type="password" name="senha" placeholder="Sua senha" autocomplete="current-password" required>
      </label>
      <button type="submit">Entrar</button>
    </form>
  </main>
</body>
</html>
