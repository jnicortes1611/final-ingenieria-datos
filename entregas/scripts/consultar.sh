#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

ETAPA="$1"
SQL="$2"
RESULTADO="$3"

REGION="$(terraform -chdir=infraestructura output -raw region)"
DATABASE="$(terraform -chdir=infraestructura output -raw base_datos)"
WORKGROUP="$(terraform -chdir=infraestructura output -raw workgroup)"

ID="$(aws athena start-query-execution \
  --region "$REGION" \
  --work-group "$WORKGROUP" \
  --query-execution-context "Database=$DATABASE" \
  --query-string "file://$SQL" \
  --query QueryExecutionId --output text)"

echo "Ejecucion: $ID"

for ((intento=0; intento<120; intento++)); do
  ESTADO="$(aws athena get-query-execution \
    --region "$REGION" --query-execution-id "$ID" \
    --query QueryExecution.Status.State --output text)"
  case "$ESTADO" in
    SUCCEEDED) break ;;
    FAILED|CANCELLED)
      aws athena get-query-execution \
        --region "$REGION" --query-execution-id "$ID" \
        --query QueryExecution.Status
      exit 1 ;;
  esac
  sleep 2
done

if [[ "$ESTADO" != "SUCCEEDED" ]]; then
  echo "Tiempo de espera agotado. Revisar ejecucion $ID."
  exit 1
fi

UBICACION="$(aws athena get-query-execution \
  --region "$REGION" --query-execution-id "$ID" \
  --query QueryExecution.ResultConfiguration.OutputLocation --output text)"

mkdir -p "$(dirname "$RESULTADO")" evidencias
aws s3 cp "$UBICACION" "$RESULTADO" --region "$REGION"

if [[ ! -f evidencias/ejecuciones_athena.csv ]]; then
  echo 'etapa,archivo_sql,id_ejecucion,archivo_resultado' \
    > evidencias/ejecuciones_athena.csv
fi

printf '%s,%s,%s,%s\n' "$ETAPA" "$SQL" "$ID" "$RESULTADO" \
  >> evidencias/ejecuciones_athena.csv

cat "$RESULTADO"
