# Ventas diarias con control de actualidad

## Entorno y ejecución
Windows con Ubuntu WSL2 y Docker Desktop.
Imagen del docente: smendezm/examen-ventas:1.0.
Desde esta carpeta, seguir la preparación oficial de ENUNCIADO.md.
Si el entorno ya está preparado, conservar su .env y ejecutar:
docker compose up -d --wait airflow
bash scripts/examen.sh check

No ejecutar docker compose down -v.

## Cambios
Solo se modificaron estos tres archivos del proyecto oficial:
- dbt/models/ventas_diarias.sql
- dbt/models/sources.yml
- airflow/dags/examen_ventas.py

El modelo agrupa por fecha y conserva precisión decimal.
Freshness advierte después de 12 horas y falla después de 24.
El DAG ejecuta comprobar_actualidad antes de construir_resumen,
reutilizando run_dbt, con all_success y propagación de errores.

## Validación reproducible
1. Ejecutar bash scripts/examen.sh scenario actualizada.
2. Ejecutar bash scripts/examen.sh dbt build para comprobar el modelo.
3. Preparar nuevamente el escenario actualizada.
4. Disparar el DAG examen_ventas desde Airflow y guardar estados y logs.
5. Consultar analytics.ventas_diarias y guardar el resumen anterior.
6. Sin tareas activas, ejecutar bash scripts/examen.sh scenario desactualizada.
7. Disparar una nueva ejecución del DAG, sin limpiar la anterior.
8. Guardar los estados y el log de freshness.
9. Repetir la consulta y comparar ambos resúmenes.
No ejecutar build manualmente durante la demostración del bloqueo.

## Resultados verificados
Fuente actualizada: freshness y build en success.
Fuente desactualizada: freshness failed y build upstream_failed, sin ejecutarse.
La comparación de resúmenes antes y después no mostró diferencias.

Resumen obtenido:
2026-01-10: 2 ventas, 3 unidades, ingreso 46.00.
2026-01-11: 3 ventas, 6 unidades, ingreso 51.25.
2026-01-12: 1 venta, 4 unidades, ingreso 12.40.

## Evidencias y respuestas
Consultar evidencias/ y evidencias/respuestas.md.
Se incluyen capturas de ambas ejecuciones, log del fallo de freshness
y consultas del resumen antes y después del bloqueo.

## Incidencia del entorno
El servidor web presentó un PID obsoleto durante el arranque.
Se recreó el contenedor Airflow conservando los volúmenes y la
infraestructura oficial.

## Seguridad
No se incluyen .env, credenciales, imágenes Docker ni volúmenes.
