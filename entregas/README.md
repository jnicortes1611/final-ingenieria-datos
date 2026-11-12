# Examen final — Entregas

## Prerrequisitos
AWS CLI v2, Terraform >= 1.5, Git, Python 3 y Bash.
Ejecución desde EC2 Ubuntu mediante SSH, con rol IAM asociado.
Región: us-east-2. Versiones reales: evidencias/versiones.txt.
No se usan claves de acceso en el código.

## Arquitectura
CSV → S3 → tabla externa Glue con partition projection → Athena.
Bucket privado con bloqueo de acceso público.
Prefijos separados: entregas/ y resultados-athena/.
Recursos y nombres reales: evidencias/outputs.json.

## Despliegue
Todos los comandos se ejecutan desde la raíz del repositorio en EC2.
1. Configurar AWS_REGION y AWS_DEFAULT_REGION como us-east-2.
2. Definir TF_VAR_nombre_bucket con un nombre único que comience con final-ingdatos-.
3. Ejecutar terraform -chdir=infraestructura init.
4. Ejecutar terraform -chdir=infraestructura validate.
5. Ejecutar terraform -chdir=infraestructura apply.
6. Guardar la salida en evidencias/aplicacion_terraform.txt.
7. Guardar terraform -chdir=infraestructura output -json en evidencias/outputs.json.

El proveedor se fija mediante infraestructura/.terraform.lock.hcl.
Los estados Terraform son locales y no deben publicarse.

## Carga inicial
Recuperar el nombre del bucket mediante:
terraform -chdir=infraestructura output -raw bucket

Subir individualmente con aws s3 cp:
- data/entregas/fecha=2026-10-01/entregas.csv a s3://<bucket>/entregas/fecha=2026-10-01/entregas.csv
- data/entregas/fecha=2026-10-02/entregas.csv a s3://<bucket>/entregas/fecha=2026-10-02/entregas.csv

No subir todavía el día 3 ni modificar los CSV suministrados.

## Consultas
El script se invoca como:
bash scripts/consultar.sh <etapa> <archivo_sql> <archivo_resultado>

El script utiliza la base, región y workgroup creados por Terraform.
Espera el éxito de Athena, descarga el CSV y registra el identificador en
evidencias/ejecuciones_athena.csv.

Para la etapa inicial, ejecutar:
- consultas/verificacion_inicial.sql
- consultas/intentos_por_fecha_estado.sql
- consultas/porcentaje_exito_por_fecha_ciudad.sql
- consultas/duracion_promedio_2026-10-02.sql

Guardar cada CSV en resultados/inicial/ con el mismo nombre base del SQL.
Validar con: python3 scripts/comparar.py inicial

## Incorporación del tercer día
Subir únicamente data/entregas/fecha=2026-10-03/entregas.csv a
s3://<bucket>/entregas/fecha=2026-10-03/entregas.csv.

Sin modificar infraestructura ni tabla, ejecutar con etapa final:
- consultas/verificacion_tercer_dia.sql
- consultas/total_registros.sql
- consultas/intentos_por_fecha_estado.sql
- consultas/porcentaje_exito_por_fecha_ciudad.sql

Guardar cada CSV en resultados/final/ con el mismo nombre base del SQL.
Validar con: python3 scripts/comparar.py final

La proyección ya cubre 2026-10-01 hasta 2026-10-03, con intervalo diario.
No se ejecutan crawlers, MSCK REPAIR TABLE ni altas de particiones.

## Resultados comprobados
- Inicial: 12 registros; agregados coincidentes con las referencias.
- Duración promedio del día 2: 36.67 minutos, solo entregas exitosas.
- Final: seis registros del tercer día y 18 registros totales.
- Agregados finales coincidentes con las referencias.
- Porcentajes y promedio con dos decimales.
Los resultados reales están en resultados/; las referencias originales,
en resultados_esperados/. Los identificadores están en evidencias/.

## Limpieza
Primero conservar los resultados y evidencias localmente.
Recuperar el bucket con terraform output y definir TF_VAR_nombre_bucket
con ese mismo valor antes de destruir.
Vaciar únicamente ese bucket mediante aws s3 rm s3://<bucket>/ --recursive.
Ejecutar terraform -chdir=infraestructura destroy y guardar su salida en
evidencias/eliminacion_terraform.txt.
Comprobar Destroy complete! y que terraform state list no muestre recursos.

La EC2 y su rol son herramientas de ejecución creadas por separado.
Se eliminan después de recuperar y publicar la entrega.

## Uso de IA y seguridad
Adjuntar el hilo completo utilizado durante el examen.
No publicar credenciales, llaves privadas, .env, planes ni estados Terraform.
