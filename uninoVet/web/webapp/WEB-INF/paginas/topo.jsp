<%@ page import="br.uninovet.*, java.util.*" %>
<%
  Usuario usuario = (Usuario) request.getAttribute("usuario");
  String base = (String) request.getAttribute("base");
  String csrf = (String) request.getAttribute("csrf");
  String aviso = (String) request.getAttribute("aviso");
  String erro = (String) request.getAttribute("erro");
%>
<!DOCTYPE html>
<html lang="pt-br">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>UninoVet - <%= Html.esc(titulo) %></title>
  <link rel="stylesheet" href="<%= base %>/estilo.css">
</head>
<body>
  <header>
    <div class="barra">
      <h1>UninoVet <span class="sub">Clínica</span></h1>
      <form method="post" action="<%= base %>/logout" class="sair">
        <input type="hidden" name="csrf" value="<%= csrf %>">
        <span><%= Html.esc(usuario.nome) %> &middot; <%= Html.esc(usuario.perfil) %></span>
        <button type="submit" class="claro">Sair</button>
      </form>
    </div>
    <nav>
      <a href="<%= base %>/painel">Painel</a>
      <a href="<%= base %>/agenda">Agenda</a>
<% if (usuario.isEquipeDeAgenda()) { %>
      <a href="<%= base %>/solicitacoes">Solicitações</a>
<% } %>
<% if (usuario.isGerente()) { %>
      <a href="<%= base %>/usuarios">Usuários</a>
      <a href="<%= base %>/admin">Admin (banco)</a>
<% } %>
    </nav>
  </header>
  <main>
<% if (aviso != null) { %>
    <p class="aviso ok"><%= Html.esc(aviso) %></p>
<% } %>
<% if (erro != null) { %>
    <p class="aviso erro"><%= Html.esc(erro) %></p>
<% } %>
