package br.uninovet;

// Erro esperado de regra de negocio (permissao, horario ocupado, dado invalido).
// Carrega o status HTTP que a API deve devolver.
public class ErroNegocio extends RuntimeException {

    public final int status;

    public ErroNegocio(int status, String mensagem) {
        super(mensagem);
        this.status = status;
    }

    public static ErroNegocio invalido(String mensagem) {
        return new ErroNegocio(400, mensagem);
    }

    public static ErroNegocio proibido(String mensagem) {
        return new ErroNegocio(403, mensagem);
    }

    public static ErroNegocio naoEncontrado(String mensagem) {
        return new ErroNegocio(404, mensagem);
    }

    public static ErroNegocio conflito(String mensagem) {
        return new ErroNegocio(409, mensagem);
    }
}
