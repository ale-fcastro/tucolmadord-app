import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'platform/db_factory.dart';

/// Base de datos local — fuente de verdad de la operación del colmado.
/// La app funciona 100% contra esta base; la sincronización con el
/// servidor (cuando exista) se hace vía `sync_queue`, nunca al revés.
class AppDatabase {
  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    configureDatabaseFactory();
    final path = join(await getDatabasesPath(), 'tucolmadord.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL,
        cost REAL,
        mode TEXT NOT NULL,
        category TEXT NOT NULL,
        is_frequent INTEGER NOT NULL DEFAULT 0,
        track_stock INTEGER NOT NULL DEFAULT 0,
        stock REAL,
        min_stock REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id TEXT PRIMARY KEY,
        total REAL NOT NULL,
        payment_method TEXT NOT NULL,
        customer_id TEXT,
        received_amount REAL,
        change_amount REAL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_items (
        id TEXT PRIMARY KEY,
        sale_id TEXT NOT NULL,
        product_id TEXT,
        product_name TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit_price REAL,
        line_total REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE fiado_customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE fiado_movements (
        id TEXT PRIMARY KEY,
        customer_id TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT,
        payment_method TEXT,
        sale_id TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES fiado_customers (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        concept TEXT NOT NULL,
        category TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE cash_closings (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL UNIQUE,
        total_sales REAL NOT NULL,
        sales_count INTEGER NOT NULL,
        cash_total REAL NOT NULL,
        transfer_total REAL NOT NULL,
        fiado_total REAL NOT NULL,
        expenses_total REAL NOT NULL,
        estimated_profit REAL NOT NULL,
        closed_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        retry_count INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        last_attempt_at TEXT
      )
    ''');
  }
}
