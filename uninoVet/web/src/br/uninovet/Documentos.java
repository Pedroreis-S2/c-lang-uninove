package br.uninovet;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.InputStream;
import java.nio.file.Files;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.List;
import java.util.Map;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

// Receitas, laudos e outros arquivos das consultas. O arquivo fica numa pasta
// (volume do Docker) com nome sorteado; no banco ficam so os dados. Nunca
// servimos a pasta direto: todo download passa pela checagem de permissao.
public class Documentos {

    public static final long TAMANHO_MAXIMO_BYTES = 5L * 1024 * 1024;

    // Link de download vale so 2 minutos e so para aquele documento.
    private static final int SEGUNDOS_DO_LINK = 120;
    private static final byte[] SEGREDO_DO_LINK = sortearSegredo();

    public static class Arquivo {
        public int consultaId;
        public String nomeOriginal;
        public String tipoConteudo;
        public File arquivo;
    }

    public static File pasta() {
        String caminho = System.getenv().getOrDefault("UPLOADS_DIR", "/uploads");
        File pasta = new File(caminho);
        pasta.mkdirs();
        return pasta;
    }

    // Somente o veterinario da consulta anexa documento.
    public static int salvar(Usuario usuario, int consultaId, String tipo, String nomeOriginal,
            InputStream conteudo) throws Exception {
        if (!usuario.isVeterinario()) {
            throw ErroNegocio.proibido("Somente o veterinario anexa documentos.");
        }
        boolean isTipoValido = "RECEITA".equals(tipo) || "LAUDO".equals(tipo) || "OUTRO".equals(tipo);
        if (!isTipoValido) {
            throw ErroNegocio.invalido("Tipo invalido. Use RECEITA, LAUDO ou OUTRO.");
        }
        String nomeLimpo = limparNome(nomeOriginal);
        String extensao = extensaoDe(nomeLimpo);
        byte[] bytes = lerComLimite(conteudo);
        conferirTipoDoArquivo(extensao, bytes);

        try (Connection conexao = Banco.abrir()) {
            Consultas.Dados consulta = Consultas.carregar(conexao, consultaId);
            Consultas.exigirAcesso(usuario, consulta);

            String nomeSalvo = sortearNome() + "." + extensao;
            File destino = new File(pasta(), nomeSalvo);
            Files.write(destino.toPath(), bytes);

            PreparedStatement comando = conexao.prepareStatement(
                    "INSERT INTO documento (consulta_id, tipo, nome_arquivo, arquivo, enviado_por) "
                            + "VALUES (?, ?, ?, ?, ?)",
                    Statement.RETURN_GENERATED_KEYS);
            comando.setInt(1, consultaId);
            comando.setString(2, tipo);
            comando.setString(3, nomeLimpo);
            comando.setString(4, nomeSalvo);
            comando.setInt(5, usuario.id);
            comando.executeUpdate();
            ResultSet chaves = comando.getGeneratedKeys();
            chaves.next();
            return chaves.getInt(1);
        }
    }

    public static List<Map<String, Object>> listar(Usuario usuario, int consultaId) throws Exception {
        try (Connection conexao = Banco.abrir()) {
            Consultas.Dados consulta = Consultas.carregar(conexao, consultaId);
            Consultas.exigirAcesso(usuario, consulta);
            PreparedStatement comando = conexao.prepareStatement(
                    "SELECT d.id, d.consulta_id, d.tipo, d.nome_arquivo, d.criado_em, u.nome AS enviado_por "
                            + "FROM documento d JOIN usuario u ON u.id = d.enviado_por "
                            + "WHERE d.consulta_id = ? ORDER BY d.id");
            comando.setInt(1, consultaId);
            return Json.linhas(comando.executeQuery());
        }
    }

    public static Arquivo abrir(Usuario usuario, int documentoId) throws Exception {
        Arquivo arquivo = carregarArquivo(documentoId);
        try (Connection conexao = Banco.abrir()) {
            Consultas.Dados consulta = Consultas.carregar(conexao, arquivo.consultaId);
            Consultas.exigirAcesso(usuario, consulta);
        }
        return arquivo;
    }

    // O app nao consegue abrir o arquivo mandando o token; por isso pede um link
    // temporario (assinado) depois que a permissao foi conferida.
    public static String gerarLink(Usuario usuario, int documentoId) throws Exception {
        abrir(usuario, documentoId);
        long expira = System.currentTimeMillis() / 1000 + SEGUNDOS_DO_LINK;
        String assinatura = assinar(documentoId + "|" + expira);
        return "/api/documentos/" + documentoId + "/arquivo?exp=" + expira + "&sig=" + assinatura;
    }

    public static Arquivo abrirComLink(int documentoId, String expiraTexto, String assinatura) throws Exception {
        long expira;
        try {
            expira = Long.parseLong(expiraTexto);
        } catch (Exception e) {
            throw ErroNegocio.proibido("Link invalido.");
        }
        boolean isExpirado = expira < System.currentTimeMillis() / 1000;
        String esperada = assinar(documentoId + "|" + expira);
        boolean isAssinaturaValida = assinatura != null
                && MessageDigest.isEqual(esperada.getBytes(), assinatura.getBytes());
        if (isExpirado || !isAssinaturaValida) {
            throw ErroNegocio.proibido("Link invalido ou expirado.");
        }
        return carregarArquivo(documentoId);
    }

    private static Arquivo carregarArquivo(int documentoId) throws Exception {
        try (Connection conexao = Banco.abrir()) {
            PreparedStatement comando = conexao.prepareStatement(
                    "SELECT consulta_id, nome_arquivo, arquivo FROM documento WHERE id = ?");
            comando.setInt(1, documentoId);
            ResultSet resultado = comando.executeQuery();
            if (!resultado.next()) {
                throw ErroNegocio.naoEncontrado("Documento nao encontrado.");
            }
            Arquivo arquivo = new Arquivo();
            arquivo.consultaId = resultado.getInt("consulta_id");
            arquivo.nomeOriginal = resultado.getString("nome_arquivo");
            arquivo.arquivo = new File(pasta(), resultado.getString("arquivo"));
            arquivo.tipoConteudo = tipoDeConteudo(extensaoDe(arquivo.nomeOriginal));
            if (!arquivo.arquivo.exists()) {
                throw ErroNegocio.naoEncontrado("Arquivo nao encontrado.");
            }
            return arquivo;
        }
    }

    private static String assinar(String texto) throws Exception {
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(SEGREDO_DO_LINK, "HmacSHA256"));
        byte[] assinatura = mac.doFinal(texto.getBytes());
        StringBuilder hexa = new StringBuilder();
        for (byte parte : assinatura) {
            hexa.append(String.format("%02x", parte));
        }
        return hexa.toString();
    }

    private static byte[] sortearSegredo() {
        byte[] segredo = new byte[32];
        SecureRandom sorteio = new SecureRandom();
        sorteio.nextBytes(segredo);
        return segredo;
    }

    private static byte[] lerComLimite(InputStream conteudo) throws Exception {
        ByteArrayOutputStream saida = new ByteArrayOutputStream();
        byte[] bloco = new byte[8192];
        int lidos = conteudo.read(bloco);
        while (lidos != -1) {
            saida.write(bloco, 0, lidos);
            if (saida.size() > TAMANHO_MAXIMO_BYTES) {
                throw ErroNegocio.invalido("Arquivo maior que 5 MB.");
            }
            lidos = conteudo.read(bloco);
        }
        if (saida.size() == 0) {
            throw ErroNegocio.invalido("Arquivo vazio.");
        }
        return saida.toByteArray();
    }

    // Confere a extensao e tambem os primeiros bytes (nao basta confiar no nome).
    private static void conferirTipoDoArquivo(String extensao, byte[] bytes) {
        boolean isPdf = bytes.length > 4 && bytes[0] == '%' && bytes[1] == 'P' && bytes[2] == 'D' && bytes[3] == 'F';
        boolean isJpg = bytes.length > 3 && (bytes[0] & 0xFF) == 0xFF && (bytes[1] & 0xFF) == 0xD8
                && (bytes[2] & 0xFF) == 0xFF;
        boolean isPng = bytes.length > 4 && (bytes[0] & 0xFF) == 0x89 && bytes[1] == 'P' && bytes[2] == 'N'
                && bytes[3] == 'G';
        boolean isCorreto = ("pdf".equals(extensao) && isPdf)
                || (("jpg".equals(extensao) || "jpeg".equals(extensao)) && isJpg)
                || ("png".equals(extensao) && isPng);
        if (!isCorreto) {
            throw ErroNegocio.invalido("Envie um arquivo PDF, JPG ou PNG valido.");
        }
    }

    private static String limparNome(String nomeOriginal) {
        if (nomeOriginal == null || nomeOriginal.trim().isEmpty()) {
            throw ErroNegocio.invalido("Informe o nome do arquivo.");
        }
        String nome = nomeOriginal.replace('\\', '/');
        nome = nome.substring(nome.lastIndexOf('/') + 1);
        nome = nome.replaceAll("[^A-Za-z0-9._ -]", "_");
        if (nome.length() > 160) {
            nome = nome.substring(nome.length() - 160);
        }
        return nome;
    }

    private static String extensaoDe(String nome) {
        int ponto = nome.lastIndexOf('.');
        if (ponto < 0) {
            throw ErroNegocio.invalido("O arquivo precisa ter extensao (pdf, jpg ou png).");
        }
        return nome.substring(ponto + 1).toLowerCase();
    }

    private static String tipoDeConteudo(String extensao) {
        if ("pdf".equals(extensao)) {
            return "application/pdf";
        }
        if ("png".equals(extensao)) {
            return "image/png";
        }
        return "image/jpeg";
    }

    private static String sortearNome() {
        byte[] bytes = new byte[16];
        SecureRandom sorteio = new SecureRandom();
        sorteio.nextBytes(bytes);
        StringBuilder nome = new StringBuilder();
        for (byte parte : bytes) {
            nome.append(String.format("%02x", parte));
        }
        return nome.toString();
    }
}
