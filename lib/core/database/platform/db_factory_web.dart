import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Solo para probar la app en Chrome durante desarrollo — el target real
/// es Android/iOS con el `sqflite` nativo (ver db_factory_io.dart).
void configureDatabaseFactory() {
  // Sin shared worker: evita depender de cross-origin isolation
  // (COOP/COEP) solo para poder previsualizar en Chrome durante desarrollo.
  databaseFactory = databaseFactoryFfiWebNoWebWorker;
}
