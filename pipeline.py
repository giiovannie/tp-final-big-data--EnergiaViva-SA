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

    total = con.execute("SELECT COUNT(*) FROM raw_lecturas").fetchone()[0]
    print(f"Registros cargados en EnergiaVivaSA_raw: {total}")


def main():
    con = duckdb.connect(str(DB_PATH))

    try:
        extract(con)
    finally:
        con.close()


if __name__ == "__main__":
    main()
