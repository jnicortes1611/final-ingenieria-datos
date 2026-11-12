# Respuestas conceptuales

## ¿Por qué usar _loaded_at y no fecha_venta?
_loaded_at registra cuándo llegó la información al sistema. fecha_venta
representa la fecha del negocio y puede ser antigua aunque la carga sea
reciente. Para este control se compara la carga más reciente con la hora
actual. Esto no garantiza que hayan llegado todas las ventas esperadas.

## ¿Por qué las pruebas de integridad no garantizan actualidad?
La unicidad, los campos obligatorios y los valores válidos comprueban
propiedades del contenido. Una fuente antigua puede cumplir todas esas
condiciones. Por eso el DAG ejecuta source freshness antes de dbt build.
En la prueba desactualizada, freshness falló y el build quedó
upstream_failed, conservando el resumen anterior.
