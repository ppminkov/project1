
/*

# Use external postgres command "vacuumlo" to calculate how many orphaned
# large objects it would remove if executed in the vcac db
#     su - postgres
#     /opt/vmware/vpostgres/current/bin/vacuumlo -n -v -p 5432 vcac

-- Execute the following SQL in psql with \a (unalign) option set so
-- the results don't display a "+" at in place of each newline.
-- Note: Some vcac db table names are case-sensitive (saas schema).

-- GENERATE UNIONED SUBQUERY OF EACH TABLE COLUMN THAT IS AN OID TYPE
SELECT string_agg(col, E'\nUNION\n') AS s
FROM (
    SELECT format('SELECT %I AS loid, ''%I.%I.%I'' AS col FROM %I.%I AS col', column_name, table_schema, table_name, column_name, table_schema, table_name) AS col
    FROM information_schema.columns
    WHERE data_type = 'oid'
        AND table_schema NOT IN ('pg_catalog', 'information_schema')
    GROUP BY table_schema, table_name, column_name
    ORDER BY LOWER(table_schema || table_name || column_name)
    ) z;

*/

WITH loid_sizes AS (
    WITH loid_columns AS (
        -- START: GENERATED SUBQUERY OF OID COLUMNS IN THE CURRENT DB
        SELECT saml AS loid, 'public.auth_usertoken.saml' AS col FROM public.auth_usertoken AS col
        UNION
        SELECT signing_key AS loid, 'public.auth_usertoken.signing_key' AS col FROM public.auth_usertoken AS col
        UNION
        SELECT image AS loid, 'public.cat_icon.image' AS col FROM public.cat_icon AS col
        UNION
        SELECT output AS loid, 'public.cluster_commands.output' AS col FROM public.cluster_commands AS col
        UNION
        SELECT config AS loid, 'public.cluster_config.config' AS col FROM public.cluster_config AS col
        UNION
        SELECT data AS loid, 'public.cms_data.data' AS col FROM public.cms_data AS col
        UNION
        SELECT attributebytes AS loid, 'public.embeddedlicenseentry.attributebytes' AS col FROM public.embeddedlicenseentry AS col
        UNION
        SELECT data AS loid, 'public.file_image.data' AS col FROM public.file_image AS col
        UNION
        SELECT data AS loid, 'public.notification_attachments.data' AS col FROM public.notification_attachments AS col
        UNION
        SELECT image AS loid, 'public.work_item_action_icon.image' AS col FROM public.work_item_action_icon AS col
        UNION
        SELECT jar AS loid, 'saas."AdaptorBundle".jar' AS col FROM saas."AdaptorBundle" AS col
        UNION
        SELECT jar AS loid, 'saas."ProvisioningBundle".jar' AS col FROM saas."ProvisioningBundle" AS col
        -- END: GENERATED SUBQUERY OF OID COLUMNS IN THE CURRENT DB
    ),
    pg_lo AS (
        SELECT lo.loid, SUM(LENGTH(lo.data)) AS bytes
        FROM pg_largeobject lo
        GROUP BY lo.loid
    )
    SELECT DISTINCT l.loid, p.loid AS ploid, l.col, p.bytes
    FROM pg_lo p
    LEFT JOIN loid_columns l
        ON l.loid = p.loid
)
-- SUMMARY TOTALS
SELECT *
FROM (
    SELECT NULL AS loid, 'TOTAL: TABLE SIZE ON DISK' AS col, pg_table_size('pg_largeobject'::regclass) AS bytes, pg_size_pretty(pg_table_size('pg_largeobject'::regclass)) AS size, NULL::bigint AS cnt
    UNION ALL
    SELECT NULL AS loid, 'TOTAL: INDEXES SIZE ON DISK' AS col, pg_indexes_size('pg_largeobject'::regclass) AS bytes, pg_size_pretty(pg_indexes_size('pg_largeobject'::regclass)) AS size, NULL::bigint AS cnt
    UNION ALL
    SELECT NULL AS loid, NULL AS col, NULL AS bytes, NULL AS size, NULL::bigint AS cnt
    UNION ALL
    SELECT NULL AS loid, 'TOTAL: ALL LOBS' AS col, SUM(bytes) AS bytes, pg_size_pretty(SUM(bytes)) AS size, COUNT(DISTINCT ploid) AS cnt
    FROM loid_sizes
    UNION ALL
    SELECT NULL AS loid, 'TOTAL: LINKED LOBS' AS col, SUM(bytes) AS bytes, pg_size_pretty(SUM(bytes)) AS size, COUNT(DISTINCT ploid) AS cnt
    FROM loid_sizes
    WHERE loid IS NOT NULL
    UNION ALL
    SELECT NULL AS loid, 'TOTAL: ORPHANED LOBS' AS col, SUM(bytes) AS bytes, pg_size_pretty(SUM(bytes)) AS size, COUNT(DISTINCT ploid) AS cnt
    FROM loid_sizes
    WHERE loid IS NULL
    UNION ALL
    SELECT NULL AS loid, NULL AS col, NULL AS bytes, NULL AS size, NULL::bigint AS cnt
    ) a
UNION ALL
-- TOTAL LOB SIZE/COUNT BY TABLE/COLUMN
SELECT *
FROM (
    SELECT NULL::text AS loid, col, SUM(bytes), pg_size_pretty(SUM(bytes)) AS size, COUNT(DISTINCT ploid) AS cnt
    FROM loid_sizes
    GROUP BY col
    ORDER BY SUM(bytes) DESC
    ) b
/*
UNION ALL
-- INDIVIDUAL LOB SIZES (BE CAREFUL WHEN UNCOMMENTING THIS, COULD BE MILLIONS OF ROWS)
SELECT NULL AS loid, NULL AS col, NULL::bigint AS bytes, NULL AS size, NULL::bigint AS cnt
UNION ALL
SELECT *
FROM (
    SELECT ploid::text, col, bytes, pg_size_pretty(bytes) AS size, NULL::bigint AS cnt
    FROM loid_sizes
    ORDER BY bytes DESC
    ) c;
*/
;


