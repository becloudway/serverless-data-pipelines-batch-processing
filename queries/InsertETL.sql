INSERT INTO "anpr"."sls_data_pipelines_batch_transformed"
SELECT uniqueId, recordTimestamp, currentSpeed, bezettingsgraad, previousSpeed,
CASE WHEN (avgSpeed3Minutes BETWEEN 0 AND 40) THEN 1
WHEN (avgSpeed3Minutes BETWEEN 41 AND 250) THEN 0
ELSE -1 END as trafficJamIndicator,
CASE WHEN (avgSpeed20Minutes BETWEEN 0 AND 40) THEN 1
WHEN (avgSpeed20Minutes BETWEEN 41 AND 250) THEN 0
ELSE -1 END as trafficJamIndicatorLong,
trafficIntensityClass2, trafficIntensityClass3, trafficIntensityClass4, trafficIntensityClass5,
speedDiffindicator, avgSpeed3Minutes, avgSpeed20Minutes, year, month, day, hour
FROM
(
SELECT uniqueId, recordTimestamp, currentSpeed, bezettingsgraad, previousSpeed,
trafficIntensityClass2, trafficIntensityClass3, trafficIntensityClass4, trafficIntensityClass5,
CASE
WHEN (currentSpeed - previousSpeed >= 20) THEN 1
WHEN (currentSpeed - previousSpeed <= -20) THEN -1
ELSE 0 END AS speedDiffindicator,
avg(currentSpeed) OVER (PARTITION BY uniqueId ORDER BY originalTimestamp ROWS BETWEEN 2 PRECEDING AND 0 FOLLOWING) AS avgSpeed3Minutes,
avg(currentSpeed) OVER (PARTITION BY uniqueId ORDER BY originalTimestamp ROWS BETWEEN 19 PRECEDING AND 0 FOLLOWING) AS avgSpeed20Minutes,
year(originalTimestamp) as year, month(originalTimestamp) as month, day(originalTimestamp) as day, hour(originalTimestamp) as hour FROM
(
SELECT uniqueId, recordTimestamp, originalTimestamp, currentSpeed, bezettingsgraad, trafficIntensityClass2,
trafficIntensityClass3, trafficIntensityClass4, trafficIntensityClass5,
lag(currentSpeed, 1) OVER (PARTITION BY uniqueId ORDER BY originalTimestamp) as previousSpeed FROM
(
SELECT MAX(uniqueId) as uniqueId, lve_nr, originalTimestamp, recordTimestamp, AVG(currentSpeed) as currentSpeed,
TRY(CAST(SUM(trafficIntensityClass2) AS INTEGER)) as trafficIntensityClass2,
TRY(CAST(SUM(trafficIntensityClass3) AS INTEGER)) as trafficIntensityClass3,
TRY(CAST(SUM(trafficIntensityClass4) AS INTEGER)) as trafficIntensityClass4,
TRY(CAST(SUM(trafficIntensityClass5) AS INTEGER)) as trafficIntensityClass5,
TRY(CAST(ROUND(AVG(bezettingsgraad)) AS INTEGER)) as bezettingsgraad FROM
(
SELECT lve_nr,
unieke_id as uniqueId,
from_unixtime(CAST(tijd_waarneming as INTEGER)) as originalTimestamp,
tijd_waarneming as recordTimestamp,
CASE WHEN verkeersintensiteit_klasse2 + verkeersintensiteit_klasse3 + verkeersintensiteit_klasse4 + verkeersintensiteit_klasse5 > 0 THEN
(voertuigsnelheid_rekenkundig_klasse2 + voertuigsnelheid_rekenkundig_klasse3 + voertuigsnelheid_rekenkundig_klasse4 + voertuigsnelheid_rekenkundig_klasse5)/
(CASE WHEN verkeersintensiteit_klasse2 > 0 THEN 1 ELSE 0 END +
CASE WHEN verkeersintensiteit_klasse3 > 0 THEN 1 ELSE 0 END +
CASE WHEN verkeersintensiteit_klasse4 > 0 THEN 1 ELSE 0 END +
CASE WHEN verkeersintensiteit_klasse5 > 0 THEN 1 ELSE 0 END)
END
as currentSpeed,
verkeersintensiteit_klasse2 as trafficIntensityClass2,
verkeersintensiteit_klasse3 as trafficIntensityClass3,
verkeersintensiteit_klasse4 as trafficIntensityClass4,
verkeersintensiteit_klasse5 as trafficIntensityClass5,
verkeersintensiteit_klasse2 + verkeersintensiteit_klasse3 + verkeersintensiteit_klasse4 + verkeersintensiteit_klasse5 as bezettingsgraad FROM
"anpr"."sls_data_pipelines_batch_destination_parquet"
WHERE rekendata_bezettingsgraad > -1 AND defect=0)
WHERE year(originalTimestamp)={year} AND month(originalTimestamp)={month} AND day(originalTimestamp) BETWEEN {start_day} AND {end_day}
AND uniqueId IN (32, 37, 1840, 2125, 3388, 3391, 753, 1065, 3159, 2161, 216, 217, 1132)
GROUP BY lve_nr, originalTimestamp, recordTimestamp
)
)
)