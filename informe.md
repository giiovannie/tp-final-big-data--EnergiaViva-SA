# Informe – Trabajo Práctico Final de Big Data

## 1. Introducción

El objetivo de este trabajo fue desarrollar un proceso ETL para el conjunto de datos de EnergiaViva S.A., aplicando técnicas de extracción, validación, limpieza y transformación mediante Python y DuckDB.

Además, se buscó construir un pipeline que permitiera ejecutar todas las etapas de manera ordenada y automatizada, para finalmente obtener información útil mediante consultas SQL.

## 2. Análisis exploratorio y toma de decisiones

Antes de comenzar con el desarrollo del pipeline, realicé una exploración completa del archivo CSV proporcionado con pandas y jupiter notebook.

Primero investigué si los datos cumplían con las características y condiciones establecidas en la consigna. Luego evalué cada columna individualmente para identificar inconsistencias, valores nulos, formatos incorrectos y posibles duplicados.

A partir de este análisis, investigué las causas de los problemas encontrados y definí cómo tratar cada caso.

### 2.1. Problemas encontrados en los datos originales

Durante la exploración se identificaron las siguientes inconsistencias:

| Columna        | Problema detectado                  |    Registros afectados |
| -------------- | ----------------------------------- | ---------------------: |
| `fecha_hora`   | Fechas con formatos diferentes      |                    262 |
| `barrio`       | Espacios adicionales                |                    157 |
| `tipo_cliente` | Mayúsculas, minúsculas y espacios   |                    206 |
| `consumo_kwh`  | Formatos numéricos con coma decimal |                    152 |
| `consumo_kwh`  | Valores negativos                   |                     95 |
| `tarifa_kwh`   | Valores nulos                       |                    129 |
| `importe`      | Valores nulos                       |                    127 |
| `id_lectura`   | Identificadores duplicados          | 145 filas involucradas |


### 2.2. Decisiones de limpieza

A partir de los problemas encontrados, se tomaron las siguientes decisiones:

- **Fechas:** se detectaron dos formatos diferentes. Se decidió normalizarlos a un único formato.
- **Barrios:** se encontraron valores con espacios adicionales. Se decidió eliminarlos mediante una limpieza de texto.
- **Tipos de cliente:** se detectaron diferencias entre mayúsculas, minúsculas y espacios. Se normalizaron utilizando minúsculas y eliminando espacios innecesarios.
- **Consumos:** se encontraron valores con coma decimal y separadores de miles. Se decidió convertirlos a un formato numérico válido. También se corrigieron los consumos negativos mediante el valor absoluto, considerando que correspondían a errores de signo.
- **Tarifas:** se identificaron valores nulos. Se decidió recuperarlos utilizando la tarifa correspondiente a cada tipo de cliente: residencial (95,50), comercial (120,25) e industrial (80).
- **Importes:** se encontraron valores nulos que debían calcularse a partir del consumo y la tarifa correspondiente.
- **Identificadores duplicados:** se decidió identificar los registros repetidos y evitar que quedaran identificadores duplicados en la tabla final. Se comprobó que los registros repetidos tenían los mismos datos y se utilizó `UNION` para eliminar las filas completamente idénticas durante la unión.

Estas decisiones permitieron establecer las reglas que posteriormente se utilizaron durante la validación y limpieza.

## 3. Desarrollo del proceso ETL

Una vez finalizado el análisis exploratorio y definidas las reglas de tratamiento, organice el proyecto siguiendo la arquitectura solicitada en la consigna.

El proceso se desarrolló en las siguientes etapas:

### 3.1. Extracción

Se utilizó Python para ejecutar el proceso y DuckDB como motor de base de datos.

El archivo CSV original se cargó en una tabla denominada `raw_energia`, conservando los valores originales como texto para evitar modificaciones automáticas durante la carga.

### 3.2. Validación

Se evaluaron los registros de acuerdo con las reglas definidas durante el análisis exploratorio.

Los registros se separaron en dos tablas:

- `validos`: registros que cumplían con las condiciones establecidas.
- `rechazados`: registros que presentaban uno o más problemas.

En esta etapa también se registraron los motivos de rechazo mediante la columna `motivo_rechazo`.

### 3.3. Limpieza

Se trabajó sobre los registros rechazados para recuperar aquellos que podían corregirse.

Se normalizaron fechas, barrios y tipos de cliente; se corrigieron los formatos numéricos y se recuperaron las tarifas e importes faltantes.

Los registros que presentaban únicamente el motivo de rechazo por identificador duplicado se excluyeron de la recuperación. Los demás registros se conservaron y corrigieron cuando fue posible.

El resultado se almacenó en `rechazados_limpios`.

### 3.4. Unión

Una vez finalizadas las etapas anteriores, se unieron los registros válidos con los registros recuperados.

Durante esta etapa se transformaron las columnas a sus tipos de datos correspondientes y se utilizó `UNION` para evitar conservar filas completamente idénticas.

El resultado se almacenó en `tabla_final`, que se utilizó como fuente para las consultas de negocio.

## 4. Resultados del procesamiento

Los resultados obtenidos durante la ejecución del pipeline fueron:

| Etapa                            | Registros |
| -------------------------------- | --------: |
| Datos originales (`raw_energia`) |      2575 |
| Registros válidos                |      1367 |
| Registros rechazados             |      1208 |
| Registros recuperables           |      1138 |
| Tabla final (`tabla_final`)      |      2467 |

De los 1208 registros rechazados, se pudieron recuperar 1138. Los 70 restantes fueron excluidos porque presentaban únicamente identificadores duplicados.

Al unir los registros válidos y recuperados se eliminaron 38 filas completamente repetidas. Por este motivo, el total final fue de 2467 registros.

Finalmente, se verificó que la cantidad de registros coincidiera con la cantidad de identificadores únicos, obteniendo 2467 registros y 2467 identificadores distintos. Esto permitió comprobar que no quedaron identificadores duplicados en `tabla_final`.

## 5. Preguntas de negocio y resultados

Una vez construida la tabla final, se realizaron cinco consultas SQL para responder las preguntas de negocio planteadas en la consigna.

Las consultas se almacenaron en `preguntas.sql` y se integraron al pipeline para que sus resultados se obtuvieran automáticamente después de completar el proceso ETL.

### 5.1. ¿Cuál es el consumo total por tipo de cliente?

Se agrupó la información por tipo de cliente y se sumaron los consumos registrados.

| Tipo de cliente | Consumo total (kWh) |
| --------------- | ------------------: |
| Industrial      |          808.956,93 |
| Comercial       |          363.073,24 |
| Residencial     |          116.224,10 |

**Resultado:** el tipo de cliente industrial presenta el mayor consumo total, seguido por el comercial y el residencial.

### 5.2. ¿Qué barrio tiene el mayor consumo total?

Se agruparon los consumos por barrio y se identificó el que presenta el mayor valor acumulado.

| Barrio | Consumo total (kWh) |
| ------ | ------------------: |
| Norte  |          290.808,12 |

**Resultado:** el barrio Norte registra el mayor consumo total.

### 5.3. ¿Cuánto se facturó por mes durante los primeros seis meses?

Se agruparon los importes por mes, considerando el período comprendido entre enero y junio de 2024.

| Mes     |  Facturación |
| ------- | -----------: |
| Enero   | 5.376.677,56 |
| Febrero | 4.070.125,08 |
| Marzo   | 6.151.557,54 |
| Abril   | 3.520.591,06 |
| Mayo    | 6.017.045,86 |
| Junio   | 5.670.113,92 |

**Resultado:** marzo fue el mes con mayor facturación, mientras que abril presentó la menor.

### 5.4. ¿Cuáles son los cinco medidores con mayor consumo?

Se agruparon los registros por identificador de medidor y se sumaron sus consumos, ordenándolos de mayor a menor.

| Medidor | Consumo total (kWh) |
| ------- | ------------------: |
| MED0038 |           19.160,26 |
| MED0154 |           17.532,85 |
| MED0076 |           13.298,74 |
| MED0015 |           13.149,43 |
| MED0022 |           12.855,59 |

**Resultado:** el medidor MED0038 presenta el mayor consumo acumulado.

### 5.5. ¿Cuál es el consumo promedio por barrio?

Se calculó el promedio de consumo de los registros correspondientes a cada barrio.

| Barrio | Consumo promedio (kWh) |
| ------ | ---------------------: |
| Norte  |                 558,17 |
| Oeste  |                 545,85 |
| Este   |                 522,97 |
| Sur    |                 514,64 |
| Centro |                 466,19 |

**Resultado:** el barrio Norte presenta el mayor consumo promedio, mientras que Centro registra el menor.

## 6. Automatización con Apache Airflow

**Pendiente de completar:** en esta sección se documentará la configuración del DAG, la programación diaria a las 2:00 AM y la ejecución automática del pipeline.


