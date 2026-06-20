wildfires = LOAD '/user/vaal/bigdata_incendios/raw/wildfires.csv'
    USING PigStorage(',')
    AS (
        fire_year:int,
        discovery_date:double,
        discovery_doy:int,
        stat_cause_descr:chararray,
        fire_size:double,
        fire_size_class:chararray,
        latitude:double,
        longitude:double,
        state:chararray,
        cont_date:double,
        cont_doy:double,
        owner_descr:chararray
    );

wildfires_clean = FILTER wildfires BY fire_year > 1990;

por_owner = GROUP wildfires_clean BY owner_descr;
resumen_owner = FOREACH por_owner GENERATE
    group AS propietario,
    COUNT(wildfires_clean) AS total,
    AVG(wildfires_clean.fire_size) AS promedio_acres;
resumen_owner_ord = ORDER resumen_owner BY total DESC;

por_clase = GROUP wildfires_clean BY fire_size_class;
resumen_clase = FOREACH por_clase GENERATE
    group AS clase,
    COUNT(wildfires_clean) AS total,
    AVG(wildfires_clean.fire_size) AS promedio_acres;
resumen_clase_ord = ORDER resumen_clase BY total DESC;

STORE resumen_owner_ord INTO '/user/vaal/bigdata_incendios/pig_output/por_propietario'
    USING PigStorage(',');
STORE resumen_clase_ord INTO '/user/vaal/bigdata_incendios/pig_output/por_clase'
    USING PigStorage(',');
