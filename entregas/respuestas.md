# Respuestas

## 1. ¿Por qué se consultó el tercer día sin registrar una partición?

La tabla tenía partition projection habilitada desde el despliegue, con un
rango del 2026-10-01 al 2026-10-03 e intervalo diario. Athena calcula las
ubicaciones usando la plantilla entregas/fecha=${fecha}/.

Después de subir el tercer CSV, se ejecutaron nuevamente las consultas sin
modificar la tabla ni registrar particiones. Los resultados finales,
identificados en evidencias/ejecuciones_athena.csv, coincidieron con las
referencias: seis registros del tercer día y 18 en total.

## 2. ¿Qué ocurriría con un archivo del 4 de octubre?

Su fecha está fuera del rango proyectado. Aunque el objeto exista en S3,
Athena no lo incluiría al consultar esta tabla con la configuración actual.
Para incorporarlo habría que ampliar projection.fecha.range en Terraform,
aplicar el cambio y consultar de nuevo. No sería necesario registrar una
partición individual.
