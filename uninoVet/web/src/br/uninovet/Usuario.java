package br.uninovet;

import java.util.LinkedHashMap;
import java.util.Map;

// Quem esta logado. tutorId so existe para CLIENTE e veterinarioId so para VETERINARIO.
public class Usuario {

    public static final String CLIENTE = "CLIENTE";
    public static final String VETERINARIO = "VETERINARIO";
    public static final String SECRETARIO = "SECRETARIO";
    public static final String GERENTE = "GERENTE";

    public final int id;
    public final String nome;
    public final String email;
    public final String perfil;
    public final Integer tutorId;
    public final Integer veterinarioId;

    public Usuario(int id, String nome, String email, String perfil, Integer tutorId, Integer veterinarioId) {
        this.id = id;
        this.nome = nome;
        this.email = email;
        this.perfil = perfil;
        this.tutorId = tutorId;
        this.veterinarioId = veterinarioId;
    }

    public boolean isCliente() {
        return CLIENTE.equals(perfil);
    }

    public boolean isVeterinario() {
        return VETERINARIO.equals(perfil);
    }

    public boolean isSecretario() {
        return SECRETARIO.equals(perfil);
    }

    public boolean isGerente() {
        return GERENTE.equals(perfil);
    }

    // Secretario e gerente cuidam da agenda e das solicitacoes.
    public boolean isEquipeDeAgenda() {
        return isSecretario() || isGerente();
    }

    public Map<String, Object> paraJson() {
        Map<String, Object> dados = new LinkedHashMap<>();
        dados.put("id", id);
        dados.put("nome", nome);
        dados.put("email", email);
        dados.put("perfil", perfil);
        dados.put("tutor_id", tutorId);
        dados.put("veterinario_id", veterinarioId);
        return dados;
    }
}
