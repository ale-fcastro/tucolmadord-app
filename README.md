# TuColmadoRD

App móvil de punto de venta para colmados dominicanos — ventas, inventario, fiados, gastos y cierre de caja, funcionando **100% offline** con SQLite como fuente de verdad local. La sincronización con un servidor es un paso futuro, no un requisito para operar.

## Stack

- Flutter + BLoC/Cubit + `get_it` para inyección de dependencias
- SQLite (`sqflite`) local, con una cola de sincronización (`sync_queue`) ya modelada para cuando exista backend
- Arquitectura por feature (`core/ features/ shared/`)

## Funcionalidad

- **Vender**: catálogo por categorías, productos por unidad/peso/importe, carrito, cobro en efectivo/transferencia/fiado
- **Inventario**: alta de productos, control de stock y stock mínimo
- **Fiados**: clientes a crédito, historial de movimientos, registro de pagos
- **Gastos**: registro y consulta por categoría
- **Cierre de caja**: resumen diario de ventas, gastos y ganancia estimada

## Correr el proyecto

```bash
flutter pub get
flutter run
```
