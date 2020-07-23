INSERT INTO "anpr"."sls_data_pipelines_batch_transformed"
SELECT uniqueId, recordTimestamp, currentSpeed, bezettingsgraad, previousSpeed,
CASE WHEN (avgSpeed2Minutes BETWEEN 0 AND 40) THEN 1
WHEN (avgSpeed2Minutes BETWEEN 41 AND 250) THEN 0
ELSE -1 END as trafficJamIndicator,
CASE WHEN (avgSpeed20Minutes BETWEEN 0 AND 40) THEN 1
WHEN (avgSpeed20Minutes BETWEEN 41 AND 250) THEN 0
ELSE -1 END as trafficJamIndicatorLong,
trafficIntensityClass2, trafficIntensityClass3, trafficIntensityClass4, trafficIntensityClass5,
speedDiffindicator, avgSpeed2Minutes, avgSpeed20Minutes, year, month, day, hour
FROM
(
SELECT uniqueId, recordTimestamp, currentSpeed, bezettingsgraad, previousSpeed,
trafficIntensityClass2, trafficIntensityClass3, trafficIntensityClass4, trafficIntensityClass5,
CASE
WHEN (currentSpeed - previousSpeed >= 20) THEN 1
WHEN (currentSpeed - previousSpeed <= -20) THEN -1
ELSE 0 END AS speedDiffindicator,
avg(NULLIF(currentSpeed, -1)) OVER (PARTITION BY uniqueId ORDER BY minutes ROWS BETWEEN 2 PRECEDING AND 0 FOLLOWING) AS avgSpeed2Minutes,
avg(NULLIF(currentSpeed, -1)) OVER (PARTITION BY uniqueId ORDER BY minutes ROWS BETWEEN 20 PRECEDING AND 0 FOLLOWING) AS avgSpeed20Minutes,
year(originalTimestamp) as year, month(originalTimestamp) as month, day(originalTimestamp) as day, hour(originalTimestamp) as hour FROM
(
SELECT uniqueId, recordTimestamp, originalTimestamp, currentSpeed, bezettingsgraad, trafficIntensityClass2,
trafficIntensityClass3, trafficIntensityClass4, trafficIntensityClass5,
date_diff('minute', DATE '2000-01-01', originalTimestamp) as minutes,
lag(currentSpeed, 1) OVER (PARTITION BY uniqueId ORDER BY originalTimestamp) as previousSpeed FROM
(
SELECT unieke_id as uniqueId,
from_unixtime(CAST(tijd_waarneming as INTEGER)) as originalTimestamp,
tijd_waarneming as recordTimestamp,
CASE WHEN verkeersintensiteit_klasse2 + verkeersintensiteit_klasse3 + verkeersintensiteit_klasse4 + verkeersintensiteit_klasse5 > 0 THEN
(voertuigsnelheid_rekenkundig_klasse2 + voertuigsnelheid_rekenkundig_klasse3 + voertuigsnelheid_rekenkundig_klasse4 + voertuigsnelheid_rekenkundig_klasse5)/
(CASE WHEN verkeersintensiteit_klasse2 > 0 THEN 1 ELSE 0 END +
CASE WHEN verkeersintensiteit_klasse3 > 0 THEN 1 ELSE 0 END +
CASE WHEN verkeersintensiteit_klasse4 > 0 THEN 1 ELSE 0 END +
CASE WHEN verkeersintensiteit_klasse5 > 0 THEN 1 ELSE 0 END)
ELSE -1 END
as currentSpeed,
verkeersintensiteit_klasse2 as trafficIntensityClass2,
verkeersintensiteit_klasse3 as trafficIntensityClass3,
verkeersintensiteit_klasse4 as trafficIntensityClass4,
verkeersintensiteit_klasse5 as trafficIntensityClass5,
verkeersintensiteit_klasse2 + verkeersintensiteit_klasse3 + verkeersintensiteit_klasse4 + verkeersintensiteit_klasse5 as bezettingsgraad FROM
"anpr"."sls_data_pipelines_batch_destination_parquet")
WHERE year(originalTimestamp)={year} AND month(originalTimestamp)={month} AND day(originalTimestamp) BETWEEN {start_day} AND {end_day}
AND bezettingsgraad > -1 AND uniqueId IN (32, 37, 1840, 2125, 3388, 3391, 753, 1065, 3159, 2161, 216, 1132)
)
)