package br.uninovet;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

// Na primeira subida (tabela usuario vazia) cria os usuarios de demonstracao e
// liga cada um ao tutor/veterinario de exemplo. Feito em Java porque o hash da
// senha (PBKDF2 com sal) nao da para calcular dentro do init.sql.
//
// So para desenvolvimento e apresentacao: troque ou remova essas senhas em producao.
@WebListener
public class Semente implements ServletContextListener {

    private static final int TENTATIVAS = 30;

    @Override
    public void contextInitialized(ServletContextEvent evento) {
        // Cookie da sessao do painel nao pode ser lido por JavaScript.
        evento.getServletContext().getSessionCookieConfig().setHttpOnly(true);
        for (int tentativa = 1; tentativa <= TENTATIVAS; tentativa++) {
            try (Connection conexao = Banco.abrir()) {
                criarUsuariosDeExemplo(conexao);
                return;
            } catch (Exception e) {
                System.out.println("[Semente] banco ainda indisponivel (" + tentativa + "): " + e.getMessage());
                esperar();
            }
        }
    }

    private void criarUsuariosDeExemplo(Connection conexao) throws Exception {
        ResultSet total = conexao.createStatement().executeQuery("SELECT COUNT(*) FROM usuario");
        total.next();
        if (total.getInt(1) > 0) {
            return;
        }
        criar(conexao, "Gerente da Clinica", "gerente@uninovet.com", "gerente123", Usuario.GERENTE);
        criar(conexao, "Secretaria Paula", "secretaria@uninovet.com", "secretaria123", Usuario.SECRETARIO);

        ligar(conexao, "UPDATE veterinario SET usuario_id = ? WHERE id = 1",
                criar(conexao, "Dra. Marina Reis", "marina@uninovet.com", "vet12345", Usuario.VETERINARIO));
        ligar(conexao, "UPDATE veterinario SET usuario_id = ? WHERE id = 2",
                criar(conexao, "Dr. Paulo Nunes", "paulo@uninovet.com", "vet12345", Usuario.VETERINARIO));
        ligar(conexao, "UPDATE veterinario SET usuario_id = ? WHERE id = 3",
                criar(conexao, "Dra. Julia Castro", "julia@uninovet.com", "vet12345", Usuario.VETERINARIO));

        ligar(conexao, "UPDATE tutor SET usuario_id = ? WHERE id = 1",
                criar(conexao, "Ana Souza", "ana.souza@email.com", "cliente123", Usuario.CLIENTE));
        ligar(conexao, "UPDATE tutor SET usuario_id = ? WHERE id = 2",
                criar(conexao, "Bruno Lima", "bruno.lima@email.com", "cliente123", Usuario.CLIENTE));
        ligar(conexao, "UPDATE tutor SET usuario_id = ? WHERE id = 3",
                criar(conexao, "Carla Mendes", "carla.mendes@email.com", "cliente123", Usuario.CLIENTE));
        System.out.println("[Semente] usuarios de demonstracao criados.");
    }

    private int criar(Connection conexao, String nome, String email, String senha, String perfil) throws Exception {
        PreparedStatement comando = conexao.prepareStatement(
                "INSERT INTO usuario (nome, email, senha_hash, perfil) VALUES (?, ?, ?, ?)",
                java.sql.Statement.RETURN_GENERATED_KEYS);
        comando.setString(1, nome);
        comando.setString(2, email);
        comando.setString(3, Senha.gerarHash(senha));
        comando.setString(4, perfil);
        comando.executeUpdate();
        ResultSet chaves = comando.getGeneratedKeys();
        chaves.next();
        return chaves.getInt(1);
    }

    private void ligar(Connection conexao, String sql, int usuarioId) throws Exception {
        PreparedStatement comando = conexao.prepareStatement(sql);
        comando.setInt(1, usuarioId);
        comando.executeUpdate();
    }

    private void esperar() {
        try {
            Thread.sleep(2000);
        } catch (Exception e) {
            Thread.currentThread().interrupt();
        }
    }
}
