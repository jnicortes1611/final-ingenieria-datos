import csv
import sys
from decimal import Decimal

etapa = sys.argv[1]
pares = [
    ("intentos_por_fecha_estado.csv",
     f"intentos_por_fecha_estado_{etapa}.csv"),
    ("porcentaje_exito_por_fecha_ciudad.csv",
     f"porcentaje_exito_por_fecha_ciudad_{etapa}.csv"),
]
if etapa == "inicial":
    pares.append(("duracion_promedio_2026-10-02.csv",
                  "duracion_promedio_2026-10-02.csv"))

for obtenido, esperado in pares:
    with open(f"resultados/{etapa}/{obtenido}", newline="") as f:
        actual = list(csv.reader(f))
    with open(f"resultados_esperados/{esperado}", newline="") as f:
        referencia = list(csv.reader(f))
    assert actual == referencia, f"NO COINCIDE: {obtenido}"
    print(f"OK: {etapa}/{obtenido}")

if etapa == "inicial":
    with open("resultados/inicial/verificacion_inicial.csv", newline="") as f:
        filas = list(csv.DictReader(f))
    assert len(filas) == 1 and int(filas[0]["total_registros"]) == 12
    print("OK: 12 registros iniciales")
else:
    with open("resultados/final/verificacion_tercer_dia.csv", newline="") as f:
        filas = list(csv.DictReader(f))
    assert len(filas) == 6
    assert all(f["fecha"] == "2026-10-03" for f in filas)
    with open("resultados/final/total_registros.csv", newline="") as f:
        totales = list(csv.DictReader(f))
    assert len(totales) == 1 and int(totales[0]["total_registros"]) == 18
    print("OK: 6 registros del tercer dia y 18 en total")
