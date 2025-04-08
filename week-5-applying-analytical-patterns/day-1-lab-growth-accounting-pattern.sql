-- Applying Analytical Patterns Day 1 - Lab
-- We are going to do Growth Accounting from the Cumulation Patterns
-- First we have to prepare our input dataset so its in daily grain - daily user metrics
-- The query below shows the source url destinations that we are going to take into account when preparing our daily metrics table
SELECT 
*
FROM bootcamp.web_events
WHERE url IN ('/signup', '/', '/contact')
LIMIT 50

-- DDL Statement to create our daily metrics table
CREATE TABLE bt_learning.bootcamp_web_events_daily(
	user_id BIGINT,
	signup_page_visits BIGINT,
	landing_page_visits BIGINT,
	contact_page_visits BIGINT,
	total_page_visits	BIGINT,
	ds DATE
)
WITH (
	format = 'PARQUET',
	partitioning = ARRAY['ds']
)

-- Inserting data into our daily metrics table
INSERT INTO bt_learning.bootcamp_web_events_daily
SELECT
	user_id,
	COUNT(CASE WHEN url = '/signup' THEN 1 END) AS signup_page_visits,
	COUNT(CASE WHEN url = '/' THEN 1 END) AS landing_page_visits,
	COUNT(CASE WHEN url = '/contact' THEN 1 END) AS contact_page_visits,
	COUNT(1) AS total_page_visits,
	DATE(event_time) AS ds
FROM bootcamp.web_events
WHERE event_time BETWEEN DATE('2023-01-01') AND DATE('2023-12-31')
-- IN normal pipeline this CONDITION would be FOR SPECIFIC DAY (yesterday, today) AS we ARE working WITH cumulative TABLE design so we ARE inserting latest DATA INTO our TABLE which already CONTAINS cumulated history
GROUP BY user_id, DATE(event_time)

-- Inspecting table that we have created and inserted data into
-- We now have 1 row per user per day here
-- We can now use this daily grain to build our stage transition tracking
SELECT *
FROM bt_learning.bootcamp_web_events_daily

-- DDL Statement to create our state tracking table
DROP TABLE bt_learning.bootcamp_state_tracking

CREATE TABLE bt_learning.bootcamp_state_tracking(
	user_id BIGINT,
	first_active_date DATE,
	last_active_date DATE,
	current_state VARCHAR, -- churned, ressurected etc.
	-- we could also create something like a datelist of all the days that user was active, however its not necessary as we already have the data available to us
	lifetime_page_visits BIGINT,
	ds DATE
)
WITH (
	format = 'PARQUET',
	partitioning = ARRAY['ds']
)

-- We can now do cumulation part where we are going to have previous and current data that we want to cummulate and add to the previous (already collected data)
-- We need to make the query below match the schema of the bootcamp_state_tracking table which we are going to do by using COALESCE
-- We first do the initial load of the data
INSERT INTO bt_learning.bootcamp_state_tracking
WITH yesterday AS(
	SELECT *
	FROM bt_learning.bootcamp_state_tracking
	WHERE ds = DATE('2022-12-31')
),
today AS(
	SELECT *
	FROM bt_learning.bootcamp_web_events_daily
	WHERE ds = DATE('2023-01-01')
),
combined AS(
	SELECT
		COALESCE(t.user_id, y.user_id) AS user_id,
		COALESCE(y.first_active_date, t.ds) AS first_active_date, -- either they existed in the previous partition of the data and were already active or they are a brand new user and we are going to use t.ds as their first_active_date
		COALESCE(t.ds, y.last_active_date) AS last_active_date,	--  almost the same as for first_active_date but the ordering inside COALESCE is reversed so that if there is a new record in todays data that we are adding then we want to use that date as the new last_active_date
		CASE 
			WHEN y.user_id IS NULL THEN 'new' -- IF they werent IN the previous DATA/PARTITION that means that they ARE NEW
			WHEN y.current_state IN ('new', 'ressurected', 'retained') AND t.user_id IS NULL THEN 'churned' -- IF they were active previous DAY that we have IN our dataset AND now they ARE NOT IN the todays dataset that we ARE cumulating ON top that means they churned
			WHEN y.current_state IN ('new', 'ressurected', 'retained') AND t.user_id IS NOT NULL THEN 'retained' -- same AS the CONDITION FOR churned above but its reversed, IF they were active previous DAY that we have IN our dataset AND now they ARE IN todays dataset that we ARE cumulating ON top that means that we retained them
			WHEN y.current_state IN ('churned', 'stale') AND t.user_id IS NOT NULL THEN 'ressurected' -- IF the USER was already IN the dataset but our LAST info about them was that they were NOT active but they ARE IN todays dataset that we ARE cumulating ON top that means they ressurected
			WHEN y.current_state IN ('churned', 'stale') AND t.user_id IS NULL THEN 'stale' -- were NOT active previously (were stale) AND THEy dont come back THEN they ARE still stale
			ELSE 'unknown'
		END AS current_state,
		COALESCE(y.lifetime_page_visits, 0) + COALESCE(t.total_page_visits, 0) AS lifetime_page_visits,
		DATE('2023-01-01') AS ds -- this IS the way it would be done IN the pipeline WHERE the date IS hardcoded so FOR example IN Airflow we could use the {{ds}} notation so that its ALWAYS the hardcoded date OF the pipeline run
	FROM today t
	FULL OUTER JOIN yesterday y ON t.user_id = y.user_id
)
SELECT
	*
FROM combined

-- Then to populate it further like we would in pipelines we would just bring the dates in the query forward
-- WHERE ds conditions in yesterday and today dataset + the hardcoded date in the combined dataset changed (were carried) forward compared to the initial load query
-- I am running the query multiple times thats why the dates below in those conditions are different by more than a day than the initial load query
INSERT INTO bt_learning.bootcamp_state_tracking
WITH yesterday AS(
	SELECT *
	FROM bt_learning.bootcamp_state_tracking
	WHERE ds = DATE('2023-01-04')
),
today AS(
	SELECT *
	FROM bt_learning.bootcamp_web_events_daily
	WHERE ds = DATE('2023-01-05')
),
combined AS(
	SELECT
		COALESCE(t.user_id, y.user_id) AS user_id,
		COALESCE(y.first_active_date, t.ds) AS first_active_date, -- either they existed in the previous partition of the data and were already active or they are a brand new user and we are going to use t.ds as their first_active_date
		COALESCE(t.ds, y.last_active_date) AS last_active_date,	--  almost the same as for first_active_date but the ordering inside COALESCE is reversed so that if there is a new record in todays data that we are adding then we want to use that date as the new last_active_date
		CASE 
			WHEN y.user_id IS NULL THEN 'new' -- IF they werent IN the previous DATA/PARTITION that means that they ARE NEW
			WHEN y.current_state IN ('new', 'ressurected', 'retained') AND t.user_id IS NULL THEN 'churned' -- IF they were active previous DAY that we have IN our dataset AND now they ARE NOT IN the todays dataset that we ARE cumulating ON top that means they churned
			WHEN y.current_state IN ('new', 'ressurected', 'retained') AND t.user_id IS NOT NULL THEN 'retained' -- same AS the CONDITION FOR churned above but its reversed, IF they were active previous DAY that we have IN our dataset AND now they ARE IN todays dataset that we ARE cumulating ON top that means that we retained them
			WHEN y.current_state IN ('churned', 'stale') AND t.user_id IS NOT NULL THEN 'ressurected' -- IF the USER was already IN the dataset but our LAST info about them was that they were NOT active but they ARE IN todays dataset that we ARE cumulating ON top that means they ressurected
			WHEN y.current_state IN ('churned', 'stale') AND t.user_id IS NULL THEN 'stale' -- were NOT active previously (were stale) AND THEy dont come back THEN they ARE still stale
			ELSE 'unknown'
		END AS current_state,
		COALESCE(y.lifetime_page_visits, 0) + COALESCE(t.total_page_visits, 0) AS lifetime_page_visits,
		DATE('2023-01-05') AS ds -- this IS the way it would be done IN the pipeline WHERE the date IS hardcoded so FOR example IN Airflow we could use the {{ds}} notation so that its ALWAYS the hardcoded date OF the pipeline run
	FROM today t
	FULL OUTER JOIN yesterday y ON t.user_id = y.user_id
)
SELECT
	*
FROM combined

-- Looking at the data that we have accumulated so that we can take a look at how the states changed
-- Normally since this is a cumulative table that grows as the pipeline runs we would have a query with some condition like DELETE * FROM TABLE bt_learning.bootcamp_state_tracking WHERE last_active_date > DATE('90 days ago') or similar based on retention policy to get rid of really old data so we don't hold the really old stale user data
-- Cool thing is that you can actually see how many days since they were last active by doing ds - last_active_date
-- We can also create some additional column something in the sense of lates_active_streak to be able to quickly figure out the consecutive days in which they were active
SELECT
*
FROM bt_learning.bootcamp_state_tracking

-- This is where it gets interesting because we can use our Growth Accounting cumulated table to use queries like the one below to see number of users per state for each day along with total_page views per users and state
-- Your new users on the first day should be the retained + churned users on the second date
-- We can use the results from this query to calculate the retention rate
-- What is really powerful is the fact that the produced dataset is at the user_id grain which means we can join other datasets/dimensions to it by user_id and see users per country etc.
SELECT
	ds,
	current_state,
	COUNT(DISTINCT user_id) AS number_of_users,
	SUM(lifetime_page_visits) AS total_page_views
FROM bt_learning.bootcamp_state_tracking
GROUP BY ds, current_state
ORDER BY ds, current_state
