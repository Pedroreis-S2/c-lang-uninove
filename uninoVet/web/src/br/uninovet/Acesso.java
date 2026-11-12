package br.uninovet;

import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDateTime;

import javax.servlet.http.HttpServletRequest;

// Login e sessao. O app usa token (cabecalho Authorization: Bearer, guardado
// na tabela sessao); o painel da clinica usa a sessao HTTP do Tomcat.
public class Acesso {

    private static final int DIAS_DE_SESSAO = 7;

    private static final String SELECT_USUARIO = "SELECT u.id, u.nome, u.email, u.perfil, u.senha_hash, "
            + "t.id AS tutor_id, v.id AS veterinario_id FROM usuario u "
            + "LEFT JOIN tutor t ON t.usuario_id = u.id "
            + "LEFT JOIN veterinario v ON v.usuario_id = u.id ";

    // Devolve o usuario se e-mail e senha conferem; senao devolve null.
    public static Usuario autenticar(String email, String senha) throws Exception {
        if (email == null || senha == null) {
            return null;
        }
        try (Connection conexao = Banco.abrir()) {
            PreparedStatement comando = conexao.prepareStatement(
                    SELECT_USUARIO + "WHERE u.email = ? AND u.ativo = 1");
            comando.setString(1, email.trim().toLowerCase());
            ResultSet resultado = comando.executeQuery();
            if (!resultado.next()) {
                return null;
            }
            String hashSalvo = resultado.getString("senha_hash");
            if (!Senha.conferir(senha, hashSalvo)) {
                return null;
            }
            return lerUsuario(resultado);
        }
    }

    public static String criarToken(int usuarioId) throws Exception {
        byte[] bytes = new byte[32];
        SecureRandom sorteio = new SecureRandom();
        sorteio.nextBytes(bytes);
        StringBuilder token = new StringBuilder();
        for (byte parte : bytes) {
            token.append(String.format("%02x", parte));
        }
        LocalDateTime expiraEm = Agenda.agora().plusDays(DIAS_DE_SESSAO);
        try (Connection conexao = Banco.abrir()) {
            PreparedStatement comando = conexao.prepareStatement(
                    "INSERT INTO sessao (token, usuario_id, expira_em) VALUES (?, ?, ?)");
            comando.setString(1, token.toString());
            comando.setInt(2, usuarioId);
            comando.setObject(3, expiraEm);
            comando.executeUpdate();
        }
        return token.toString();
    }

    public static Usuario porToken(String token) throws Exception {
        if (token == null || token.length() != 64) {
            return null;
        }
        try (Connection conexao = Banco.abrir()) {
            PreparedStatement comando = conexao.prepareStatement(
                    SELECT_USUARIO + "JOIN sessao s ON s.usuario_id = u.id "
                            + "WHERE s.token = ? AND s.expira_em > ? AND u.ativo = 1");
            comando.setString(1, token);
            comando.setObject(2, Agenda.agora());
            ResultSet resultado = comando.executeQuery();
            if (!resultado.next()) {
                return null;
            }
            return lerUsuario(resultado);
        }
    }

    public static void encerrarToken(String token) throws Exception {
        try (Connection conexao = Banco.abrir()) {
            PreparedStatement comando = conexao.prepareStatement("DELETE FROM sessao WHERE token = ?");
            comando.setString(1, token);
            comando.executeUpdate();
        }
    }

    // Le o cabecalho "Authorization: Bearer <token>".
    public static String tokenDaRequisicao(HttpServletRequest req) {
        String cabecalho = req.getHeader("Authorization");
        if (cabecalho == null || !cabecalho.startsWith("Bearer ")) {
            return null;
        }
        return cabecalho.substring("Bearer ".length()).trim();
    }

    // O filtro da API coloca o usuario na requisicao depois de validar o token.
    public static Usuario daRequisicao(HttpServletRequest req) {
        return (Usuario) req.getAttribute("usuario");
    }

    private static Usuario lerUsuario(ResultSet resultado) throws Exception {
        int tutorId = resultado.getInt("tutor_id");
        Integer tutor = resultado.wasNull() ? null : tutorId;
        int veterinarioId = resultado.getInt("veterinario_id");
        Integer veterinario = resultado.wasNull() ? null : veterinarioId;
        return new Usuario(
                resultado.getInt("id"),
                resultado.getString("nome"),
                resultado.getString("email"),
                resultado.getString("perfil"),
                tutor,
                veterinario);
    }
}
