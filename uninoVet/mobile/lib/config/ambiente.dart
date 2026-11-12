import 'package:flutter/foundation.dart' show kIsWeb;

// Endereco da API do painel Java.
//
// O endereco chega por argumento na hora de subir o app:
//   flutter run ... --dart-define=API_BASE=https://meu-codespace-8080.app.github.dev
// O "make uninovet" sobe o Java primeiro e passa a URL dele aqui. Sem argumento
// (uso local de sempre) o app fala com o Java em http://localhost:8080, ou usa
// caminho relativo quando estiver atras do proxy opcional.
class Ambiente {
  static const String _apiBaseArgumento = String.fromEnvironment('API_BASE');

  static String get apiBase {
    if (_apiBaseArgumento.isNotEmpty) {
      return _apiBaseArgumento;
    }
    if (kIsWeb) {
      final base = Uri.base;
      final abertoNoDevServer = base.host == 'localhost' && base.port == 5000;
      if (!abertoNoDevServer) {
        return '';
      }
    }
    return 'http://localhost:8080';
  }

  static String get agendamentos => rota('/api/agendamentos');

  // Monta o endereco completo de uma rota da API ("/api/login").
  static String rota(String caminho) => '$apiBase$caminho';
}
