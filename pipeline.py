from pathlib import Path
import duckdb

# Rutas del proyecto
BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = BASE_DIR / "datos"
SQL_DIR = BASE_DIR / "sql"
DB_PATH = BASE_DIR / "pipeline.duckdb"


def read_sql(filename):
    return (SQL_DIR / filename).read_text(encoding="utf-8")


def extract(con):
    sql = read_sql("extract.sql")
    con.execute(sql, [str(DATA_DIR / "lecturas.csv")])

    total = con.execute("SELECT COUNT(*) FROM raw_energia").fetchone()[0]
    print(f"Registros cargados en raw_energia: {total}")


def validate(con):
    sql = read_sql("validar.sql")
    con.execute(sql)

    total_validos = con.execute("SELECT COUNT(*) FROM validos").fetchone()[0]
    total_rechazados = con.execute("SELECT COUNT(*) FROM rechazados").fetchone()[0]

    print(f"Registros válidos: {total_validos}")
    print(f"Registros rechazados: {total_rechazados}")


def limpieza(con):
    sql = read_sql("limpiar.sql")
    con.execute(sql)

    total_limpios = con.execute("SELECT COUNT(*) FROM rechazados_limpios").fetchone()[0]

    print(f"Registros recuperables: {total_limpios}")


def unir(con):
    sql = read_sql("unir.sql")
    con.execute(sql)

    total = con.execute("SELECT COUNT(*) FROM tabla_final").fetchone()[0]

    print(f"Registros en tabla_final: {total}")


def main():
    con = duckdb.connect(str(DB_PATH))

    try:
        extract(con)
        validate(con)
        limpieza(con)
        unir(con)
    finally:
        con.close()


if __name__ == "__main__":
    main()
