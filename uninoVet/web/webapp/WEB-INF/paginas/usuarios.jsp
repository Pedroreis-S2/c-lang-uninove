<%@ page contentType="text/html; charset=UTF-8" %>
<% String titulo = "Usuários"; %>
<%@ include file="topo.jsp" %>
<%
  List<Map<String, Object>> usuarios = (List<Map<String, Object>>) request.getAttribute("usuarios");
%>
    <h2>Usuários</h2>
    <table>
      <thead><tr><th>Nome</th><th>E-mail</th><th>Perfil</th><th>Ativo</th><th>Ações</th></tr></thead>
      <tbody>
<% for (Map<String, Object> pessoa : usuarios) {
     boolean isAtivo = Integer.valueOf(1).equals(pessoa.get("ativo")); %>
        <tr>
          <td><%= Html.esc(pessoa.get("nome")) %></td>
          <td><%= Html.esc(pessoa.get("email")) %></td>
          <td><%= Html.esc(pessoa.get("perfil")) %></td>
          <td><%= isAtivo ? "sim" : "não" %></td>
          <td>
            <form method="post" action="<%= base %>/acoes" class="linha">
              <input type="hidden" name="csrf" value="<%= csrf %>">
              <input type="hidden" name="voltar" value="/usuarios">
              <input type="hidden" name="id" value="<%= pessoa.get("id") %>">
              <button type="submit" name="acao" value="alternar_usuario" class="link"><%= isAtivo ? "Desativar" : "Ativar" %></button>
            </form>
          </td>
        </tr>
<% } %>
      </tbody>
    </table>

    <h3>Novo funcionário</h3>
    <form method="post" action="<%= base %>/acoes" class="formulario largo">
      <input type="hidden" name="csrf" value="<%= csrf %>">
      <input type="hidden" name="acao" value="criar_usuario">
      <input type="hidden" name="voltar" value="/usuarios">
      <label>Nome <input name="nome" maxlength="120" required></label>
      <label>E-mail <input type="email" name="email" maxlength="120" required></label>
      <label>Senha (mín. 6) <input type="password" name="senha" minlength="6" required></label>
      <label>Perfil
        <select name="perfil">
          <option value="SECRETARIO">Secretário</option>
          <option value="VETERINARIO">Veterinário</option>
          <option value="GERENTE">Gerente</option>
        </select>
      </label>
      <label>CRMV (só veterinário) <input name="crmv" maxlength="20"></label>
      <label>Especialidade (só veterinário) <input name="especialidade" maxlength="80"></label>
      <button type="submit">Criar</button>
    </form>
<%@ include file="rodape.jsp" %>
