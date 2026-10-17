package br.uninovet;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

// Acesso ao banco. Como as tabelas e as colunas vem sempre da classe Tabela
// (uma lista fechada), o mesmo codigo serve para todos os cadastros.
public class Banco {

    public static Connection abrir() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String host = System.getenv().getOrDefault("DB_HOST", "db");
        String nome = System.getenv().getOrDefault("DB_NAME", "uninovet");
        String usuario = System.getenv().getOrDefault("DB_USER", "uninovet");
        String senha = System.getenv().getOrDefault("DB_PASSWORD", "uninovet");
        String url = "jdbc:mysql://" + host + ":3306/" + nome;
        return DriverManager.getConnection(url, usuario, senha);
    }

    public static List<Map<String, String>> listar(Tabela tabela) throws Exception {
        List<Map<String, String>> linhas = new ArrayList<>();
        Connection conexao = abrir();
        PreparedStatement comando = conexao.prepareStatement("SELECT * FROM " + tabela.nome() + " ORDER BY id");
        ResultSet resultado = comando.executeQuery();
        ResultSetMetaData meta = resultado.getMetaData();
        while (resultado.next()) {
            Map<String, String> linha = new LinkedHashMap<>();
            for (int i = 1; i <= meta.getColumnCount(); i++) {
                linha.put(meta.getColumnName(i), resultado.getString(i));
            }
            linhas.add(linha);
        }
        conexao.close();
        return linhas;
    }

    public static Map<String, String> buscar(Tabela tabela, int id) throws Exception {
        Map<String, String> linha = new LinkedHashMap<>();
        Connection conexao = abrir();
        PreparedStatement comando = conexao.prepareStatement("SELECT * FROM " + tabela.nome() + " WHERE id = ?");
        comando.setInt(1, id);
        ResultSet resultado = comando.executeQuery();
        ResultSetMetaData meta = resultado.getMetaData();
        if (resultado.next()) {
            for (int i = 1; i <= meta.getColumnCount(); i++) {
                linha.put(meta.getColumnName(i), resultado.getString(i));
            }
        }
        conexao.close();
        return linha;
    }

    public static void inserir(Tabela tabela, Map<String, String> dados) throws Exception {
        List<String> campos = tabela.campos();
        String colunas = String.join(", ", campos);
        String marcas = "?" + ", ?".repeat(campos.size() - 1);
        Connection conexao = abrir();
        PreparedStatement comando = conexao.prepareStatement(
                "INSERT INTO " + tabela.nome() + " (" + colunas + ") VALUES (" + marcas + ")");
        preencher(comando, campos, dados);
        comando.executeUpdate();
        conexao.close();
    }

    public static void atualizar(Tabela tabela, int id, Map<String, String> dados) throws Exception {
        List<String> campos = tabela.campos();
        StringBuilder sets = new StringBuilder();
        for (int i = 0; i < campos.size(); i++) {
            if (i > 0) {
                sets.append(", ");
            }
            sets.append(campos.get(i)).append(" = ?");
        }
        Connection conexao = abrir();
        PreparedStatement comando = conexao.prepareStatement(
                "UPDATE " + tabela.nome() + " SET " + sets + " WHERE id = ?");
        int indice = preencher(comando, campos, dados);
        comando.setInt(indice, id);
        comando.executeUpdate();
        conexao.close();
    }

    public static void excluir(Tabela tabela, int id) throws Exception {
        Connection conexao = abrir();
        PreparedStatement comando = conexao.prepareStatement("DELETE FROM " + tabela.nome() + " WHERE id = ?");
        comando.setInt(1, id);
        comando.executeUpdate();
        conexao.close();
    }

    private static int preencher(PreparedStatement comando, List<String> campos, Map<String, String> dados)
            throws Exception {
        int indice = 1;
        for (String campo : campos) {
            comando.setString(indice, dados.get(campo));
            indice++;
        }
        return indice;
    }
}
