// Quem esta logado no app. Fica so na memoria: ao recarregar a pagina o
// usuario entra de novo (nenhuma senha ou token e gravado no aparelho).
class UsuarioLogado {
  final int id;
  final String nome;
  final String email;
  final String perfil;
  final int? tutorId;
  final int? veterinarioId;

  const UsuarioLogado({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
    this.tutorId,
    this.veterinarioId,
  });

  factory UsuarioLogado.doJson(Map<String, dynamic> json) {
    return UsuarioLogado(
      id: json['id'] as int,
      nome: json['nome'] as String? ?? '',
      email: json['email'] as String? ?? '',
      perfil: json['perfil'] as String? ?? '',
      tutorId: json['tutor_id'] as int?,
      veterinarioId: json['veterinario_id'] as int?,
    );
  }

  // Iniciais para o circulo da barra: "Ana Souza" -> "AS".
  String get iniciais {
    final partes = nome.trim().split(' ');
    if (partes.isEmpty || partes.first.isEmpty) {
      return '?';
    }
    final primeira = partes.first.substring(0, 1);
    if (partes.length == 1) {
      return primeira.toUpperCase();
    }
    final ultima = partes.last.substring(0, 1);
    return (primeira + ultima).toUpperCase();
  }
}

class Sessao {
  static String? token;
  static UsuarioLogado? usuario;

  static bool get isLogado => token != null;

  static bool get isCliente {
    final atual = usuario;
    return atual != null && atual.perfil == 'CLIENTE';
  }

  static void sair() {
    token = null;
    usuario = null;
  }
}
