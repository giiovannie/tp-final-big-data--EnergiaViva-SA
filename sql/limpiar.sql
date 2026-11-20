CREATE OR REPLACE TABLE rechazados_limpios AS
SELECT *
FROM rechazados
WHERE motivo_rechazo <> 'id_lectura_duplicado';


-- con esta consulta me encargo de hacer dos cosas : pasar a formato fecha y los que tieenen el formato invertido tambnien lo cambiamos 
UPDATE rechazados_limpios
SET fecha_hora = STRFTIME(
    COALESCE(
        TRY_STRPTIME(fecha_hora, '%Y-%m-%d %H:%M:%S'),
        TRY_STRPTIME(fecha_hora, '%d/%m/%Y %H:%M:%S')
    ),
    '%Y-%m-%d %H:%M:%S'
);


-- en esta consulta vamos a limpiar los espacios ue tienen los registros de esta columan que era varios
UPDATE rechazados_limpios
SET barrio = TRIM(barrio);


-- con esta consulta tomamos la decision de pasar a minusculas los tipos de clientes como habiamos previsto en el analis 
UPDATE rechazados_limpios
SET tipo_cliente = LOWER(TRIM(tipo_cliente));


-- aca lo quevamos a hacer es corregir esas comas que no se puedan tomar 
-- Se normaliza el separador decimal y se convierten los negativos a positivos.
UPDATE rechazados_limpios
SET consumo_kwh = CAST(
    ABS(
        TRY_CAST(
            CASE
                WHEN consumo_kwh LIKE '%,%'
                THEN REPLACE(
                    REPLACE(TRIM(consumo_kwh), '.', ''),
                    ',',
                    '.'
                )
                ELSE TRIM(consumo_kwh)
            END
            AS DOUBLE
        )
    ) AS VARCHAR
);


-- aca nos encargmaos que los clientes que estaban vacios o nulos se le asigna medinte la regla que logramois deducir en el analisis previo 
UPDATE rechazados_limpios
SET tarifa_kwh = CAST(
    CASE tipo_cliente
        WHEN 'residencial' THEN 95.5
        WHEN 'comercial' THEN 120.25
        WHEN 'industrial' THEN 80
    END AS VARCHAR
)
WHERE TRY_CAST(TRIM(tarifa_kwh) AS DOUBLE) IS NULL;


-- aca vamos a transformar los a numero las coumnas de de consumo y tarifa y multiplicarlo entre si para dar el resultafo de importe que antes no habia nada ahi
UPDATE rechazados_limpios
SET importe = CAST(
    TRY_CAST(consumo_kwh AS DOUBLE) *
    TRY_CAST(tarifa_kwh AS DOUBLE)
    AS VARCHAR
)
WHERE TRY_CAST(TRIM(importe) AS DOUBLE) IS NULL;


-- previo a este sql teniamos una columna auixliar que decia el motivo de porque ese refistro se rechazaba ahora la eliminamos porque todos estan corregidos
ALTER TABLE rechazados_limpios
DROP COLUMN motivo_rechazo;
