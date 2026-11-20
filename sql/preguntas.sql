import duckdb

con = duckdb.connect("pipeline.duckdb")

resultado = con.execute("""
    SELECT
        COUNT(*) AS ids_duplicados
    FROM (
        SELECT id_lectura
        FROM tabla_final
        GROUP BY id_lectura
        HAVING COUNT(*) > 1
    );
""").fetchall()

print("IDs duplicados:", resultado)

con.close()