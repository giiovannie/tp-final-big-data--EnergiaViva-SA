
-- 1. ¿Cuál es el consumo total por tipo de cliente?

SELECT
    tipo_cliente,
    SUM(consumo_kwh) AS consumo_total
FROM tabla_final
GROUP BY tipo_cliente
ORDER BY consumo_total DESC;


-- 2. ¿Qué barrio tiene el mayor consumo total?

SELECT
    barrio,
    SUM(consumo_kwh) AS consumo_total
FROM tabla_final
GROUP BY barrio
ORDER BY consumo_total DESC
LIMIT 1;


-- 3. ¿Cuánto se facturó por mes (primeros 6 meses)?

SELECT
    STRFTIME(fecha_hora, '%Y-%m') AS mes,
    SUM(importe) AS facturacion_total
FROM tabla_final
WHERE fecha_hora >= TIMESTAMP '2024-01-01 00:00:00'
    AND fecha_hora < TIMESTAMP '2024-07-01 00:00:00'
GROUP BY mes
ORDER BY mes;


-- 4. ¿Cuáles son los 5 medidores con mayor consumo?

SELECT
    id_medidor,
    SUM(consumo_kwh) AS consumo_total
FROM tabla_final
GROUP BY id_medidor
ORDER BY consumo_total DESC
LIMIT 5;


-- 5. ¿Cuál es el consumo promedio por barrio?

SELECT
    barrio,
    AVG(consumo_kwh) AS consumo_promedio
FROM tabla_final
GROUP BY barrio
ORDER BY consumo_promedio DESC;
