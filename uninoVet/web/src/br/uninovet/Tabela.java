package br.uninovet;

import java.util.Arrays;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

// Cada cadastro do painel (tutor, veterinario, animal, consulta) e descrito por
// um objeto Tabela com o nome no banco, o titulo na tela e os campos editaveis.
public class Tabela {

    private final String nome;
    private final String titulo;
    private final List<String> campos;

    private Tabela(String nome, String titulo, String... campos) {
        this.nome = nome;
        this.titulo = titulo;
        this.campos = Arrays.asList(campos);
    }

    public String nome() {
        return nome;
    }

    public String titulo() {
        return titulo;
    }

    public List<String> campos() {
        return campos;
    }

    private static final Map<String, Tabela> REGISTRO = new LinkedHashMap<>();

    static {
        Tabela tutor = new Tabela("tutor", "Tutores", "nome", "telefone", "email");
        Tabela veterinario = new Tabela("veterinario", "Veterinários", "nome", "crmv", "especialidade");
        Tabela animal = new Tabela("animal", "Animais", "nome", "especie", "raca", "tutor_id");
        Tabela consulta = new Tabela("consulta", "Consultas", "animal_id", "veterinario_id", "data_hora", "motivo", "status");
        REGISTRO.put(tutor.nome(), tutor);
        REGISTRO.put(veterinario.nome(), veterinario);
        REGISTRO.put(animal.nome(), animal);
        REGISTRO.put(consulta.nome(), consulta);
    }

    public static Tabela por(String nome) {
        return REGISTRO.get(nome);
    }

    public static Map<String, Tabela> todas() {
        return REGISTRO;
    }
}
