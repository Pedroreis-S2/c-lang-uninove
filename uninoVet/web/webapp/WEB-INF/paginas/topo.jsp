<%@ page import="br.uninovet.*, java.util.*" %>
<%
  Usuario usuario = (Usuario) request.getAttribute("usuario");
  String base = (String) request.getAttribute("base");
  String csrf = (String) request.getAttribute("csrf");
  String aviso = (String) request.getAttribute("aviso");
  String erro = (String) request.getAttribute("erro");
  String caminhoAtual = request.getRequestURI();
  String iniciais = usuario.nome == null || usuario.nome.isEmpty() ? "?" : usuario.nome.substring(0, 1).toUpperCase();
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
<div class="app">
  <aside class="lateral">
    <a class="marca" href="<%= base %>/painel">
      <span class="logo"><%= Icones.svg("logo") %></span>
      <span><strong>UninoVet</strong><span>Clínica veterinária</span></span>
    </a>
    <nav aria-label="Menu principal">
      <a href="<%= base %>/painel" class="<%= caminhoAtual.endsWith("/painel") ? "ativo" : "" %>"><%= Icones.svg("inicio") %> Painel</a>
      <a href="<%= base %>/agenda" class="<%= caminhoAtual.endsWith("/agenda") ? "ativo" : "" %>"><%= Icones.svg("agenda") %> Agenda</a>
<% if (usuario.isEquipeDeAgenda()) { %>
      <a href="<%= base %>/solicitacoes" class="<%= caminhoAtual.endsWith("/solicitacoes") ? "ativo" : "" %>"><%= Icones.svg("solicitacoes") %> Solicitações</a>
<% } %>
<% if (usuario.isGerente()) { %>
      <div class="grupo">Gerência</div>
      <a href="<%= base %>/usuarios" class="<%= caminhoAtual.endsWith("/usuarios") ? "ativo" : "" %>"><%= Icones.svg("usuarios") %> Usuários</a>
      <a href="<%= base %>/admin" class="<%= caminhoAtual.contains("/admin") ? "ativo" : "" %>"><%= Icones.svg("banco") %> Admin (banco)</a>
<% } %>
    </nav>
    <div class="usuario-logado">
      <div class="quem">
        <span class="avatar"><%= Html.esc(iniciais) %></span>
        <div>
          <div class="nome"><%= Html.esc(usuario.nome) %></div>
          <div class="perfil"><%= Icones.rotuloPerfil(usuario.perfil) %></div>
        </div>
      </div>
      <form method="post" action="<%= base %>/logout">
        <input type="hidden" name="csrf" value="<%= csrf %>">
        <button type="submit" class="claro pequeno"><%= Icones.svg("sair") %> Sair</button>
      </form>
    </div>
  </aside>
  <div class="conteudo">
  <main>
<% if (aviso != null) { %>
    <p class="aviso ok" role="status"><%= Html.esc(aviso) %></p>
<% } %>
<% if (erro != null) { %>
    <p class="aviso erro" role="alert"><%= Html.esc(erro) %></p>
<% } %>
