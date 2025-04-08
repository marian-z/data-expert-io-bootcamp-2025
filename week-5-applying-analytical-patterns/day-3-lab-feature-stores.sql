-- This lab is going to revolve around creating feature stores for ML models
-- We are using MAPs because if we want to add new columns to the table we simply add them to the map which is flexible and we do not have to change the schema of the table
CREATE TABLE bt_learning.user_features(
	user_id BIGINT,
	features MAP(VARCHAR, DOUBLE),
	categorical_features MAP(VARCHAR, VARCHAR),
	-- pipeline_version VARCHAR -- This can be useful if we had a GIT hash so we can see what version of the pipeline produced said features and see what change in the pipeline caused the change in certain features if there was some
	ds DATE,
	feature_group VARCHAR
) WITH (
	format = 'PARQUET',
	partitioning = ARRAY['feature_group', 'ds']
)

-- In real world scenario we would want to do this with cumulative table design so that we do not have to query 1 year of data like this
INSERT INTO bt_learning.user_features
WITH device_level AS (
    SELECT
        user_id,
        device_id,
        COUNT(1) AS web_hits_1yr,
        COUNT(CASE WHEN DATE(event_time) = DATE('2023-08-01') THEN 1 END) AS web_hits_1d,
        COUNT(CASE WHEN DATE(event_time) > DATE('2023-07-25') THEN 1 END) AS web_hits_1w,
        COUNT(CASE WHEN DATE(event_time) > DATE('2023-07-01') THEN 1 END) AS web_hits_1m,
        COUNT(CASE WHEN url = '/signup' THEN 1 END) AS signup_hits_1yr,
        COUNT(CASE WHEN url = '/signup' AND DATE(event_time) = DATE('2023-08-01') THEN 1 END) AS signup_hits_1d,
        COUNT(CASE WHEN url = '/signup' AND DATE(event_time) > DATE('2023-07-25') THEN 1 END) AS signup_hits_1w,
        COUNT(CASE WHEN url = '/signup' AND DATE(event_time) > DATE('2023-07-01') THEN 1 END) AS signup_hits_1m,
        COUNT(CASE WHEN url = '/contact' THEN 1 END) AS contact_hits_1yr,
        COUNT(CASE WHEN url = '/contact' AND DATE(event_time) = DATE('2023-08-01') THEN 1 END) AS contact_hits_1d,
        COUNT(CASE WHEN url = '/contact' AND DATE(event_time) > DATE('2023-07-25') THEN 1 END) AS contact_hits_1w,
        COUNT(CASE WHEN url = '/contact' AND DATE(event_time) > DATE('2023-07-01') THEN 1 END) AS contact_hits_1m
    FROM bootcamp.web_events w
    WHERE event_time BETWEEN DATE('2022-08-01') AND DATE('2023-08-01')
    GROUP BY user_id, device_id
)
SELECT
    user_id,
    MAP(
        ARRAY[
            'web_hits_1y', 'web_hits_1d', 'web_hits_1w', 'web_hits_1m', 
            'signup_hits_1y', 'signup_hits_1d', 'signup_hits_1w', 'signup_hits_1m', 
            'contact_hits_1y', 'contact_hits_1d', 'contact_hits_1w', 'contact_hits_1m'
        ], 
        ARRAY[
            SUM(web_hits_1yr), SUM(web_hits_1d), SUM(web_hits_1w), SUM(web_hits_1m), 
            SUM(signup_hits_1yr), SUM(signup_hits_1d), SUM(signup_hits_1w), SUM(signup_hits_1m), 
            SUM(contact_hits_1yr), SUM(contact_hits_1d), SUM(contact_hits_1w), SUM(contact_hits_1m)
        ]
    ) AS features,
    MAP(
        ARRAY['primary_device_type', 'primary_os_type', 'primary_browser_type'], 
        ARRAY[
            MAX_BY(d.device_type, web_hits_1yr), 
            MAX_BY(d.os_type, web_hits_1yr), 
            MAX_BY(d.browser_type, web_hits_1yr)
        ]
    ) AS categorical_features,
    DATE('2023-08-01') AS ds,
    'web_activity_features' AS feature_group
FROM device_level dl
JOIN bootcamp.devices d ON dl.device_id = d.device_id
GROUP BY user_id;

-- One-hot encoding could be done really easily on our created table with queries like below
-- In the example below we can also see how we can easily turn our map back into columnar format where each key from the MAP is now a separate column
SELECT
	user_id,
	features['web_hits_1y'] AS web_hits_1y,
	features['web_hits_1d'] AS web_hits_1d,
	features['web_hits_1w'] AS web_hits_1w,
	features['web_hits_1m'] AS web_hits_1m,
	features['signup_hits_1y'] AS signup_hits_1y,
	features['signup_hits_1d'] AS signup_hits_1d,
	features['signup_hits_1w'] AS signup_hits_1w,
	features['signup_hits_1m'] AS signup_hits_1m,
	features['contact_hits_1y'] AS contact_hits_1y,
	features['contact_hits_1d'] AS contact_hits_1d,
	features['contact_hits_1w'] AS contact_hits_1w,
	features['contact_hits_1m'] AS contact_hits_1m,
	CASE WHEN categorical_features['primary_os_type'] = 'Android' THEN 1 ELSE 0 END AS is_android,
	CASE WHEN categorical_features['primary_os_type'] = 'iOS' THEN 1 ELSE 0 END AS is_os,
	CASE WHEN categorical_features['primary_os_type'] = 'Generic Smartphone' THEN 1 ELSE 0 END AS is_generic_smart_phone
FROM bt_learning.user_features
