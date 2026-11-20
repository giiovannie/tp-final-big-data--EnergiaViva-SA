CREATE OR REPLACE TEMP VIEW lecturas_evaluadas AS
WITH
    datos AS (
        SELECT
            *,
            COUNT(*) OVER (
                PARTITION BY
                    id_lectura
            ) AS cantidad_id
        FROM
            raw_energia
    )
SELECT
    *,
    CONCAT_WS(
        ' | ',
        CASE
            WHEN NULLIF(TRIM(id_lectura), '') IS NULL THEN 'id_lectura_nulo'
        END,
        CASE
            WHEN NULLIF(TRIM(id_lectura), '') IS NOT NULL
            AND cantidad_id > 1 THEN 'id_lectura_duplicado'
        END,
        CASE
            WHEN TRY_STRPTIME(fecha_hora, '%Y-%m-%d %H:%M:%S') IS NULL THEN 'fecha_formato_invalido'
        END,
        CASE
            WHEN NOT REGEXP_FULL_MATCH(TRIM(id_medidor), 'MED[0-9]{4}') THEN 'id_medidor_invalido'
        END,
        CASE
        WHEN NULLIF(TRIM(barrio), '') IS NULL
            OR barrio NOT IN ('Norte', 'Sur', 'Centro', 'Oeste', 'Este')
        THEN 'barrio_no_normalizado'
        END,
        CASE
            WHEN NULLIF(TRIM(tipo_cliente), '') IS NULL
                OR tipo_cliente NOT IN ('residencial', 'comercial', 'industrial')
            THEN 'tipo_cliente_no_normalizado'
        END,
        CASE
            WHEN TRY_CAST (TRIM(consumo_kwh) AS DOUBLE) IS NULL THEN 'consumo_no_numerico'
        END,
        CASE
            WHEN TRY_CAST (TRIM(consumo_kwh) AS DOUBLE) < 0 THEN 'consumo_negativo'
        END,
        CASE
            WHEN TRY_CAST (TRIM(tarifa_kwh) AS DOUBLE) IS NULL THEN 'tarifa_nula'
        END,
        CASE
            WHEN TRY_CAST (TRIM(importe) AS DOUBLE) IS NULL THEN 'importe_nulo'
        END
    ) AS motivo_rechazo
FROM
    datos;

CREATE OR REPLACE TABLE validos AS
SELECT
    * EXCLUDE (cantidad_id, motivo_rechazo)
FROM
    lecturas_evaluadas
WHERE
    motivo_rechazo = '';

CREATE OR REPLACE TABLE rechazados AS
SELECT
    * EXCLUDE (cantidad_id)
FROM
    lecturas_evaluadas
WHERE
    motivo_rechazo <> '';