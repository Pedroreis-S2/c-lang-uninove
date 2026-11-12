package br.uninovet;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

// Senha nunca e guardada pura. O formato salvo e: pbkdf2$iteracoes$sal$hash.
// Usa so o que ja vem no Java (PBKDF2), entao nao precisa de biblioteca extra.
public class Senha {

    private static final int ITERACOES = 120000;
    private static final int TAMANHO_SAL = 16;
    private static final int TAMANHO_HASH_BITS = 256;

    public static String gerarHash(String senha) {
        byte[] sal = new byte[TAMANHO_SAL];
        SecureRandom sorteio = new SecureRandom();
        sorteio.nextBytes(sal);
        byte[] hash = calcular(senha, sal, ITERACOES);
        String salTexto = Base64.getEncoder().encodeToString(sal);
        String hashTexto = Base64.getEncoder().encodeToString(hash);
        return "pbkdf2$" + ITERACOES + "$" + salTexto + "$" + hashTexto;
    }

    public static boolean conferir(String senha, String hashSalvo) {
        if (senha == null || hashSalvo == null) {
            return false;
        }
        String[] partes = hashSalvo.split("\\$");
        if (partes.length != 4 || !"pbkdf2".equals(partes[0])) {
            return false;
        }
        int iteracoes = Integer.parseInt(partes[1]);
        byte[] sal = Base64.getDecoder().decode(partes[2]);
        byte[] esperado = Base64.getDecoder().decode(partes[3]);
        byte[] calculado = calcular(senha, sal, iteracoes);
        return MessageDigest.isEqual(esperado, calculado);
    }

    private static byte[] calcular(String senha, byte[] sal, int iteracoes) {
        try {
            PBEKeySpec especificacao = new PBEKeySpec(senha.toCharArray(), sal, iteracoes, TAMANHO_HASH_BITS);
            SecretKeyFactory fabrica = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
            return fabrica.generateSecret(especificacao).getEncoded();
        } catch (Exception e) {
            throw new IllegalStateException("Nao foi possivel calcular o hash da senha", e);
        }
    }
}
