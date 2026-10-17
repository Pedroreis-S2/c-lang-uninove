// Endereco da API do painel Java. Trocar aqui muda para onde o app aponta.
// No navegador (flutter web), o localhost e a propria maquina/Codespace.
// Para rodar no Android de verdade, troque por http://10.0.2.2:8080 (emulador)
// ou pelo IP do servidor.
class Ambiente {
  static const String apiBase = 'http://localhost:8080';

  static String get agendamentos => '$apiBase/api/agendamentos';
}
