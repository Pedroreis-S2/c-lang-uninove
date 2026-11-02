import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// Na web o SQLite roda via WebAssembly. Usamos a versao sem web worker, que
// roda na propria pagina e nao exige isolamento cross-origin do servidor.
void configurarBanco() {
  databaseFactory = databaseFactoryFfiWebNoWebWorker;
}
