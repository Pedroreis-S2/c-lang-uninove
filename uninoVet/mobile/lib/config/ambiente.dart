import 'package:flutter/foundation.dart' show kIsWeb;

// Endereco da API do painel Java. Esperto para funcionar em tres situacoes,
// sem quebrar nenhuma:
//  - App aberto direto no dev server do Flutter (localhost:5000): fala com a
//    API em http://localhost:8080 (jeito local de sempre).
//  - App atras do proxy (localhost:3000 no local, ou no Codespace): mesma
//    origem, entao usa caminho relativo e o proxy manda /api para o Java.
//  - Android: aponta para o servidor configurado (troque conforme o ambiente;
//    no emulador costuma ser http://10.0.2.2:8080).
class Ambiente {
  static String get apiBase {
    if (kIsWeb) {
      final base = Uri.base;
      final abertoNoDevServer = base.host == 'localhost' && base.port == 5000;
      if (abertoNoDevServer) {
        return 'http://localhost:8080';
      }
      return '';
    }
    return 'http://localhost:8080';
  }

  static String get agendamentos => '$apiBase/api/agendamentos';
}
