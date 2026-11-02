// Escolhe a configuracao do banco conforme a plataforma, em tempo de compilacao:
// - Android/iOS/desktop (dart.library.io): o proprio plugin do sqflite cuida.
// - Web (dart.library.html): usa a implementacao em WebAssembly.
export 'config_banco_stub.dart'
    if (dart.library.io) 'config_banco_io.dart'
    if (dart.library.html) 'config_banco_web.dart';
