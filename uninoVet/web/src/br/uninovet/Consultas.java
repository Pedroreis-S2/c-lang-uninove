package br.uninovet;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

// Casos de uso das consultas: solicitar, aceitar, recusar, cancelar e concluir.
// Toda permissao e toda regra de agenda e conferida aqui (nunca so no app).
public class Consultas {

    private static final String SELECT_LISTA = "SELECT c.id, c.animal_id, a.nome AS animal, a.especie, "
            + "c.veterinario_id, v.nome AS veterinario, t.id AS tutor_id, t.nome AS tutor, "
            + "c.tipo_servico_id, s.nome AS tipo_servico, c.data_hora, c.fim, c.motivo, c.status, "
            + "c.motivo_recusa, "
            + "(SELECT COUNT(*) FROM documento d WHERE d.consulta_id = c.id) AS total_documentos "
            + "FROM consulta c "
            + "JOIN animal a ON a.id = c.animal_id "
            + "JOIN tutor t ON t.id = a.tutor_id "
            + "JOIN veterinario v ON v.id = c.veterinario_id "
            + "LEFT JOIN tipo_servico s ON s.id = c.tipo_servico_id ";

    // Dados minimos de uma consulta para decidir permissao e regra.
    public static class Dados {
        public int id;
        public int tutorId;
        public int veterinarioId;
        public String status;
        public LocalDateTime inicio;
        public LocalDateTime fim;
    }

    // Lista as consultas que o usuario pode ver (cliente: as dele; veterinario: as dele; equipe: todas).
    public static List<Map<String, Object>> listar(Usuario usuario) throws Exception {
        String filtro = "";
        Integer idFiltro = null;
        if (usuario.isCliente()) {
            filtro = "WHERE t.id = ? ";
            idFiltro = usuario.tutorId;
        } else if (usuario.isVeterinario()) {
            filtro = "WHERE c.veterinario_id = ? ";
            idFiltro = usuario.veterinarioId;
        }
        try (Connection conexao = Banco.abrir()) {
            PreparedStatement comando = conexao.prepareStatement(SELECT_LISTA + filtro + "ORDER BY c.data_hora");
            if (idFiltro != null) {
                comando.setInt(1, idFiltro);
            }
            List<Map<String, Object>> linhas = Json.linhas(comando.executeQuery());
            for (Map<String, Object> linha : linhas) {
                boolean isCancelavel = podeCancelar(usuario, linha);
                linha.put("pode_cancelar", isCancelavel);
            }
            return linhas;
        }
    }

    public static List<Map<String, Object>> listarPorStatus(String status) throws Exception {
        try (Connection conexao = Banco.abrir()) {
            PreparedStatement comando = conexao.prepareStatement(
                    SELECT_LISTA + "WHERE c.status = ? ORDER BY c.data_hora");
            comando.setString(1, status);
            return Json.linhas(comando.executeQuery());
        }
    }

    public static List<Map<String, Object>> listarDoDia(String dia, Integer veterinarioId) throws Exception {
        String filtroVeterinario = veterinarioId == null ? "" : "AND c.veterinario_id = ? ";
        try (Connection conexao = Banco.abrir()) {
            PreparedStatement comando = conexao.prepareStatement(
                    SELECT_LISTA + "WHERE DATE(c.data_hora) = ? " + filtroVeterinario + "ORDER BY c.data_hora");
            comando.setString(1, dia);
            if (veterinarioId != null) {
                comando.setInt(2, veterinarioId);
            }
            return Json.linhas(comando.executeQuery());
        }
    }

    // Cria a consulta. Cliente gera SOLICITADA (nao reserva nada); equipe gera AGENDADA direto.
    public static int criar(Usuario usuario, int animalId, int veterinarioId, int tipoServicoId,
            String dataHoraTexto, String motivo) throws Exception {
        if (!usuario.isCliente() && !usuario.isEquipeDeAgenda()) {
            throw ErroNegocio.proibido("Seu perfil nao cria agendamentos.");
        }
        if (motivo == null || motivo.trim().isEmpty() || motivo.length() > 160) {
            throw ErroNegocio.invalido("Informe o motivo (ate 160 caracteres).");
        }
        LocalDateTime inicio = Agenda.lerDataHora(dataHoraTexto);
        String status = usuario.isCliente() ? "SOLICITADA" : "AGENDADA";

        try (Connection conexao = Banco.abrir()) {
            conexao.setAutoCommit(false);
            trancarVeterinario(conexao, veterinarioId);
            validarAnimal(conexao, usuario, animalId);
            int duracao = Agenda.duracaoDoServico(conexao, tipoServicoId);
            LocalDateTime fim = inicio.plusMinutes(duracao);
            Agenda.validarHorario(inicio, fim);
            if (Agenda.temConflito(conexao, veterinarioId, inicio, fim, 0)) {
                throw ErroNegocio.conflito("Esse horario ja esta ocupado para o veterinario.");
            }
            PreparedStatement comando = conexao.prepareStatement(
                    "INSERT INTO consulta (animal_id, veterinario_id, tipo_servico_id, data_hora, fim, motivo, status) "
                            + "VALUES (?, ?, ?, ?, ?, ?, ?)",
                    Statement.RETURN_GENERATED_KEYS);
            comando.setInt(1, animalId);
            comando.setInt(2, veterinarioId);
            comando.setInt(3, tipoServicoId);
            comando.setObject(4, inicio);
            comando.setObject(5, fim);
            comando.setString(6, motivo.trim());
            comando.setString(7, status);
            comando.executeUpdate();
            ResultSet chaves = comando.getGeneratedKeys();
            chaves.next();
            int novoId = chaves.getInt(1);
            conexao.commit();
            return novoId;
        }
    }

    public static void aceitar(Usuario usuario, int id) throws Exception {
        exigirEquipe(usuario);
        try (Connection conexao = Banco.abrir()) {
            conexao.setAutoCommit(false);
            Dados consulta = carregar(conexao, id);
            trancarVeterinario(conexao, consulta.veterinarioId);
            consulta = carregar(conexao, id);
            if (!"SOLICITADA".equals(consulta.status)) {
                throw ErroNegocio.conflito("So da para aceitar uma solicitacao pendente.");
            }
            LocalDateTime fim = consulta.fim != null ? consulta.fim
                    : consulta.inicio.plusMinutes(Agenda.MINUTOS_DO_SLOT);
            Agenda.validarHorario(consulta.inicio, fim);
            if (Agenda.temConflito(conexao, consulta.veterinarioId, consulta.inicio, fim, id)) {
                throw ErroNegocio.conflito("Esse horario ja foi ocupado. Recuse ou remarque a solicitacao.");
            }
            atualizarStatus(conexao, id, "AGENDADA", null);
            conexao.commit();
        }
    }

    public static void recusar(Usuario usuario, int id, String motivoRecusa) throws Exception {
        exigirEquipe(usuario);
        try (Connection conexao = Banco.abrir()) {
            Dados consulta = carregar(conexao, id);
            if (!"SOLICITADA".equals(consulta.status)) {
                throw ErroNegocio.conflito("So da para recusar uma solicitacao pendente.");
            }
            String motivo = motivoRecusa == null || motivoRecusa.trim().isEmpty() ? null : motivoRecusa.trim();
            atualizarStatus(conexao, id, "RECUSADA", motivo);
        }
    }

    // Cliente so cancela ate 30 min antes; equipe e o veterinario da consulta cancelam sempre.
    public static void cancelar(Usuario usuario, int id) throws Exception {
        try (Connection conexao = Banco.abrir()) {
            Dados consulta = carregar(conexao, id);
            exigirAcesso(usuario, consulta);
            boolean isAtiva = "SOLICITADA".equals(consulta.status) || "AGENDADA".equals(consulta.status);
            if (!isAtiva) {
                throw ErroNegocio.conflito("Essa consulta nao pode mais ser cancelada.");
            }
            if (usuario.isCliente() && !Agenda.isCancelavelPeloCliente(consulta.inicio)) {
                throw ErroNegocio.proibido(
                        "O cancelamento pelo app so vale ate 30 minutos antes. Ligue para a clinica.");
            }
            atualizarStatus(conexao, id, "CANCELADA", null);
        }
    }

    // Somente o veterinario da consulta conclui.
    public static void concluir(Usuario usuario, int id) throws Exception {
        if (!usuario.isVeterinario()) {
            throw ErroNegocio.proibido("Somente o veterinario conclui a consulta.");
        }
        try (Connection conexao = Banco.abrir()) {
            Dados consulta = carregar(conexao, id);
            exigirAcesso(usuario, consulta);
            if (!"AGENDADA".equals(consulta.status)) {
                throw ErroNegocio.conflito("So da para concluir uma consulta agendada.");
            }
            atualizarStatus(conexao, id, "CONCLUIDA", null);
        }
    }

    // Veterinario, cliente ou equipe: quem pode ver/mexer nessa consulta.
    public static void exigirAcesso(Usuario usuario, Dados consulta) {
        boolean isDoCliente = usuario.isCliente() && usuario.tutorId != null
                && usuario.tutorId == consulta.tutorId;
        boolean isDoVeterinario = usuario.isVeterinario() && usuario.veterinarioId != null
                && usuario.veterinarioId == consulta.veterinarioId;
        if (isDoCliente || isDoVeterinario || usuario.isEquipeDeAgenda()) {
            return;
        }
        throw ErroNegocio.naoEncontrado("Consulta nao encontrada.");
    }

    public static Dados carregar(Connection conexao, int id) throws Exception {
        PreparedStatement comando = conexao.prepareStatement(
                "SELECT c.id, a.tutor_id, c.veterinario_id, c.status, c.data_hora, c.fim FROM consulta c "
                        + "JOIN animal a ON a.id = c.animal_id WHERE c.id = ?");
        comando.setInt(1, id);
        ResultSet resultado = comando.executeQuery();
        if (!resultado.next()) {
            throw ErroNegocio.naoEncontrado("Consulta nao encontrada.");
        }
        Dados dados = new Dados();
        dados.id = resultado.getInt("id");
        dados.tutorId = resultado.getInt("tutor_id");
        dados.veterinarioId = resultado.getInt("veterinario_id");
        dados.status = resultado.getString("status");
        dados.inicio = resultado.getObject("data_hora", LocalDateTime.class);
        dados.fim = resultado.getObject("fim", LocalDateTime.class);
        return dados;
    }

    private static boolean podeCancelar(Usuario usuario, Map<String, Object> linha) {
        String status = (String) linha.get("status");
        boolean isAtiva = "SOLICITADA".equals(status) || "AGENDADA".equals(status);
        if (!isAtiva) {
            return false;
        }
        if (usuario.isCliente()) {
            LocalDateTime inicio = Agenda.lerDataHora((String) linha.get("data_hora"));
            return Agenda.isCancelavelPeloCliente(inicio);
        }
        return true;
    }

    private static void exigirEquipe(Usuario usuario) {
        if (!usuario.isEquipeDeAgenda()) {
            throw ErroNegocio.proibido("Somente secretario ou gerente fazem isso.");
        }
    }

    // Serializa quem mexe na agenda do mesmo veterinario (evita dois aceites no mesmo horario).
    private static void trancarVeterinario(Connection conexao, int veterinarioId) throws Exception {
        PreparedStatement comando = conexao.prepareStatement("SELECT id FROM veterinario WHERE id = ? FOR UPDATE");
        comando.setInt(1, veterinarioId);
        ResultSet resultado = comando.executeQuery();
        if (!resultado.next()) {
            throw ErroNegocio.invalido("Veterinario invalido.");
        }
    }

    private static void validarAnimal(Connection conexao, Usuario usuario, int animalId) throws Exception {
        PreparedStatement comando = conexao.prepareStatement("SELECT tutor_id FROM animal WHERE id = ?");
        comando.setInt(1, animalId);
        ResultSet resultado = comando.executeQuery();
        if (!resultado.next()) {
            throw ErroNegocio.invalido("Pet invalido.");
        }
        int tutorDoPet = resultado.getInt("tutor_id");
        boolean isDeOutroTutor = usuario.isCliente() && (usuario.tutorId == null || usuario.tutorId != tutorDoPet);
        if (isDeOutroTutor) {
            throw ErroNegocio.invalido("Pet invalido.");
        }
    }

    private static void atualizarStatus(Connection conexao, int id, String status, String motivoRecusa)
            throws Exception {
        PreparedStatement comando = conexao.prepareStatement(
                "UPDATE consulta SET status = ?, motivo_recusa = ? WHERE id = ?");
        comando.setString(1, status);
        comando.setString(2, motivoRecusa);
        comando.setInt(3, id);
        comando.executeUpdate();
    }
}
