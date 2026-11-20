
CREATE OR REPLACE TABLE tabla_final AS

-- seleccionamos los registros que pasaron la validacion al principio para unirlo con los rechazados que fueron limpiados y transformados
SELECT DISTINCT
    id_lectura,
    TRY_STRPTIME(fecha_hora, '%Y-%m-%d %H:%M:%S') AS fecha_hora,
    id_medidor,
    barrio,
    tipo_cliente,
    TRY_CAST(consumo_kwh AS DOUBLE) AS consumo_kwh,
    TRY_CAST(tarifa_kwh AS DOUBLE) AS tarifa_kwh,
    TRY_CAST(importe AS DOUBLE) AS importe
FROM validos

UNION

-- aca nos encontramos con los rechazados coregirdos listo para serunidos con los validos
SELECT DISTINCT
    id_lectura,
    TRY_STRPTIME(fecha_hora, '%Y-%m-%d %H:%M:%S') AS fecha_hora,
    id_medidor,
    barrio,
    tipo_cliente,
    TRY_CAST(consumo_kwh AS DOUBLE) AS consumo_kwh,
    TRY_CAST(tarifa_kwh AS DOUBLE) AS tarifa_kwh,
    TRY_CAST(importe AS DOUBLE) AS importe
FROM rechazados_limpios;
