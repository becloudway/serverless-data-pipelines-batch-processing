INSERT INTO "anpr"."sls_data_pipelines_batch_transformed_parquet_athena"
SELECT uniqueId, recordTimestamp, currentSpeed, bezettingsgraad, previousSpeed, trafficJamIndicator,
CASE
WHEN (currentSpeed - previousSpeed >= 20) THEN 1
WHEN (currentSpeed - previousSpeed <= -20) THEN -1
ELSE 0 END AS speedDiffindicator,
avg(currentSpeed) OVER (PARTITION BY uniqueId ORDER BY minutes ROWS BETWEEN 2 PRECEDING AND 0 FOLLOWING) AS avgSpeed2Minutes,
avg(currentSpeed) OVER (PARTITION BY uniqueId ORDER BY minutes ROWS BETWEEN 10 PRECEDING AND 0 FOLLOWING) AS avgSpeed10Minutes,
year(originalTimestamp) as year, month(originalTimestamp) as month, day(originalTimestamp) as day, hour(originalTimestamp) as hour FROM
(
SELECT uniqueId, recordTimestamp, originalTimestamp, currentSpeed, bezettingsgraad,
CASE WHEN (currentSpeed BETWEEN 0 AND 40) AND (bezettingsgraad <> 0) THEN 1
WHEN (currentSpeed BETWEEN 41 AND 250) OR (bezettingsgraad = 0) THEN 0
ELSE -1 END as trafficJamIndicator,
date_diff('minute', DATE '2000-01-01', originalTimestamp) as minutes,
lag(currentSpeed, 1) OVER (PARTITION BY uniqueId ORDER BY originalTimestamp) as previousSpeed FROM
(
SELECT unieke_id as uniqueId,
from_unixtime(CAST(tijd_waarneming as INTEGER)) as originalTimestamp,
tijd_waarneming as recordTimestamp,
voertuigsnelheid_rekenkundig_klasse2 as currentSpeed,
rekendata_bezettingsgraad as bezettingsgraad FROM
"anpr"."sls_data_pipelines_batch_parquet_destination_parquet")
WHERE day(originalTimestamp) = 7 AND bezettingsgraad > -1 AND uniqueId IN (32, 37, 1840, 2125, 3388, 3391, 753, 1065, 3159, 2161, 216, 1132
)
)