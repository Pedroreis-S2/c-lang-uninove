package br.uninovet;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

// Regras da agenda: slots de 30 minutos, expediente, duracao do servico e
// conflito de horario. As regras ficam aqui para o painel e a API usarem as
// mesmas.
//
// Premissas (questoes em aberto dos requisitos): o conflito e por veterinario;
// a clinica abre de segunda a sabado, das 08:00 as 18:00.
public class Agenda {

    public static final int MINUTOS_DO_SLOT = 30;
    public static final int MINUTOS_ANTES_PARA_CANCELAR = 30;
    public static final LocalTime ABERTURA = LocalTime.of(8, 0);
    public static final LocalTime FECHAMENTO = LocalTime.of(18, 0);

    // Horario da clinica (o servidor pode estar em UTC, por isso fixamos).
    public static LocalDateTime agora() {
        return LocalDateTime.now(ZoneId.of("America/Sao_Paulo"));
    }

    // Aceita "2026-12-01 13:00", "2026-12-01 13:00:00" ou "2026-12-01T13:00".
    public static LocalDateTime lerDataHora(String texto) {
        if (texto == null || texto.trim().isEmpty()) {
            throw ErroNegocio.invalido("Informe a data e a hora.");
        }
        String normalizado = texto.trim().replace('T', ' ');
        if (normalizado.length() == 16) {
            normalizado = normalizado + ":00";
        }
        try {
            DateTimeFormatter formato = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            return LocalDateTime.parse(normalizado, formato);
        } catch (Exception e) {
            throw ErroNegocio.invalido("Data e hora invalidas: " + texto);
        }
    }

    public static LocalDate lerDia(String texto) {
        try {
            return LocalDate.parse(texto.trim());
        } catch (Exception e) {
            throw ErroNegocio.invalido("Data invalida: " + texto);
        }
    }

    // Devolve a duracao em minutos do servico ativo, ou erro se nao existir.
    public static int duracaoDoServico(Connection conexao, int tipoServicoId) throws Exception {
        PreparedStatement comando = conexao.prepareStatement(
                "SELECT duracao_minutos FROM tipo_servico WHERE id = ? AND ativo = 1");
        comando.setInt(1, tipoServicoId);
        ResultSet resultado = comando.executeQuery();
        if (!resultado.next()) {
            throw ErroNegocio.invalido("Tipo de servico invalido.");
        }
        return resultado.getInt("duracao_minutos");
    }

    // Confere se o intervalo e um horario possivel (futuro, slot cravado, expediente).
    public static void validarHorario(LocalDateTime inicio, LocalDateTime fim) {
        if (!inicio.isAfter(agora())) {
            throw ErroNegocio.invalido("Nao e possivel marcar no passado.");
        }
        boolean isSlotCravado = inicio.getMinute() % MINUTOS_DO_SLOT == 0 && inicio.getSecond() == 0;
        if (!isSlotCravado) {
            throw ErroNegocio.invalido("Os horarios sao de 30 em 30 minutos (ex.: 13:00, 13:30).");
        }
        if (inicio.getDayOfWeek() == DayOfWeek.SUNDAY) {
            throw ErroNegocio.invalido("A clinica nao abre aos domingos.");
        }
        boolean isMesmoDia = inicio.toLocalDate().equals(fim.toLocalDate());
        boolean isDentroDoExpediente = !inicio.toLocalTime().isBefore(ABERTURA)
                && !fim.toLocalTime().isAfter(FECHAMENTO);
        if (!isMesmoDia || !isDentroDoExpediente) {
            throw ErroNegocio.invalido("Fora do expediente (08:00 as 18:00).");
        }
    }

    // Sobreposicao: inicioA < fimB e inicioB < fimA. So reservas AGENDADA ocupam horario.
    public static boolean temConflito(Connection conexao, int veterinarioId, LocalDateTime inicio,
            LocalDateTime fim, int ignorarConsultaId) throws Exception {
        PreparedStatement comando = conexao.prepareStatement(
                "SELECT COUNT(*) FROM consulta WHERE veterinario_id = ? AND status = 'AGENDADA' "
                        + "AND id <> ? AND data_hora < ? "
                        + "AND COALESCE(fim, DATE_ADD(data_hora, INTERVAL 30 MINUTE)) > ?");
        comando.setInt(1, veterinarioId);
        comando.setInt(2, ignorarConsultaId);
        comando.setObject(3, fim);
        comando.setObject(4, inicio);
        ResultSet resultado = comando.executeQuery();
        resultado.next();
        return resultado.getInt(1) > 0;
    }

    // Horarios de inicio livres no dia, para o app mostrar so o que da para pedir.
    public static List<String> horariosLivres(Connection conexao, int veterinarioId, LocalDate dia,
            int duracaoMinutos) throws Exception {
        List<String> livres = new ArrayList<>();
        if (dia.getDayOfWeek() == DayOfWeek.SUNDAY) {
            return livres;
        }
        LocalDateTime inicio = dia.atTime(ABERTURA);
        LocalDateTime limite = dia.atTime(FECHAMENTO);
        DateTimeFormatter formatoHora = DateTimeFormatter.ofPattern("HH:mm");
        while (!inicio.plusMinutes(duracaoMinutos).isAfter(limite)) {
            LocalDateTime fim = inicio.plusMinutes(duracaoMinutos);
            boolean isFuturo = inicio.isAfter(agora());
            if (isFuturo && !temConflito(conexao, veterinarioId, inicio, fim, 0)) {
                livres.add(inicio.format(formatoHora));
            }
            inicio = inicio.plusMinutes(MINUTOS_DO_SLOT);
        }
        return livres;
    }

    public static boolean isCancelavelPeloCliente(LocalDateTime inicio) {
        LocalDateTime limite = agora().plusMinutes(MINUTOS_ANTES_PARA_CANCELAR);
        return !inicio.isBefore(limite);
    }
}
