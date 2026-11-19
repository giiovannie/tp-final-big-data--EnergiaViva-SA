CREATE OR REPLACE TABLE raw_energia AS
SELECT
    *
FROM
    read_csv_auto(?, all_varchar = TRUE);