-- Every Iceberg table you can query with $files that will provide information about the Files in the Iceberg file structure
SELECT *
FROM bootcamp."nba_player_seasons$files"
;
-- It cointains a lot of information such as:
-- filepath - you can see the location on S3 + see that partition is a folder in the filepath
-- partition - 
-- number of records
-- file size in bits
-- lower and upper bounds - can be useful for predicate pushdown and partition pruning - i.e. when we have queries with WHERE clauses it automatically knows which partitons to skip when looking for the data etc.

--------

-- You can also check informations about partitions directly
SELECT *
FROM bootcamp."nba_player_seasons$partitions"
; 

--------

-- In the results of the query below you can see that the table itself is a mess due to the fact that there is no partioning scheme
SELECT *
FROM bootcamp."nba_game_details$files"
;
-- What we will want to do is to create a partitioning schema to be able to query the table more efficiently
-- As was said in the lecture, when partitioning you generaly want to do that on a time dimension
-- Since we do not have time dimension in nba_game_details table we will want to create it with a JOIN
SELECT
	g.*,
	gd.*
FROM bootcamp.nba_game_details gd
JOIN bootcamp.nba_games g ON gd.game_id = g.game_id
;
-- We want to be careful how we partition thins because of cases such as that in NBA games one season go from one year to another (start in 2004 end in 2005) etc.
-- It is a common and good practice to contain partition column as the last column in the DDL
-- We will be trying out a few different partition schemas
CREATE OR REPLACE TABLE bt_learning.mz_nba_game_details_partitioned(
	game_id BIGINT,
	home_team_id BIGINT,
	away_team_id BIGINT,
	player_id BIGINT,
	player_name VARCHAR,
	pts INTEGER,
	reb INTEGER,
	ast INTEGER,
	stl INTEGER,
	blk INTEGER,
	season INTEGER,
	game_date_est DATE
) WITH (
	format = 'PARQUET',
	partitioning = ARRAY['season', 'year(game_date_est)']
)
;

INSERT INTO bt_learning.mz_nba_game_details_partitioned
SELECT
	g.game_id ,
	g.home_team_id,
	g.visitor_team_id AS away_team_id,
	gd.player_id,
	gd.player_name,
	gd.pts,
	gd.reb,
	gd.ast,
	gd.stl,
	gd.blk,
	g.season,
	g.game_date_est 
FROM bootcamp.nba_game_details gd
JOIN bootcamp.nba_games g ON gd.game_id = g.game_id
;

-- Look at new metadata with partitioning schema
SELECT *
FROM bt_learning."mz_nba_game_details_partitioned$files" 
;

-- Lets compare the size of the initial data and partitioned data
SELECT 'old', SUM(file_size_in_bytes) FROM bootcamp."nba_game_details$files"
UNION ALL
SELECT 'new', SUM(file_size_in_bytes) FROM bt_learning."mz_nba_game_details_partitioned$files"
;
-- We got rid of some of the columns which might also play a role in the reduced file size of new partitioned data when we run the query above
-- However the smaller size is also due to better compression as now the dataset is probably more sorted (depends on what trino does to it under the hood)

-- One thing that is weird is that even if the newly partitioned data is partitioned on YEAR(game_date_est) the query below wouldnt benefit because of partition pruning due to the concept called sargability
-- Look into sargability more - sargable == can be looked up by an index
SELECT *
FROM bt_learning.mz_nba_game_details_partitioned
WHERE YEAR(game_date_est) = 2004
;

-- What is interesting is that if we rewrote the query so it looks like as below then the partition pruning would be able to run and we would benefit from it (faster query results, better lookup)
SELECT *
FROM bt_learning.mz_nba_game_details_partitioned
WHERE game_date_est BETWEEN DATE('2004-01-01') AND DATE('2004-01-31')
;
-- Of course always keep in mind the size of your dataset to see if this will pose problems for you or not (if the data is small enough then the results from first query will be good anyway)

--------

-- We can use the query below to take a look at the snapshots
SELECT *
FROM bt_learning."mz_nba_game_details_partitioned$snapshots"
;

-- Take note of the operation column which will tell us what happened with the table
-- First commit with NULL as parent_id is always going to be the CREATE statement

--
-- If we delete from the table with query such as below we can then use the $snapshots query again to check the operation done one the table 
DELETE FROM bt_learning.mz_nba_game_details_partitioned
WHERE season = 2012
;

-- summary column contains a lot of useful information such as number of deleted records, removed file size, which partition was removed etc
SELECT *
FROM bt_learning."mz_nba_game_details_partitioned$snapshots"
;

-- Iceberg 2.0 also supports row level deletes, not only partition level deletes

--------

-- Timetravel ability will enable us to use queries such as the one below with the FOR TIMESTAMP AS OF TIMESTAMP clause
-- Timetravel buddy query
SELECT * FROM bt_learning.mz_nba_game_details_partitioned FOR TIMESTAMP AS OF TIMESTAMP '2025-01-08 14:35:18.215 +0100'
;

-- That way we can for example check which records have been deleted etc.
WITH OLD AS (
SELECT * FROM bt_learning.mz_nba_game_details_partitioned FOR TIMESTAMP AS OF TIMESTAMP '2025-01-08 14:35:18.215 +0100'
),
prod AS (
SELECT * FROM bt_learning.mz_nba_game_details_partitioned
)
SELECT o.*
FROM old o
FULL OUTER JOIN prod p ON o.player_id = p.player_id AND o.game_id = p.game_id
WHERE p.player_id IS NULL
;

-- There is also another, maybe better way that we can solve this by building a summary table
--
WITH OLD AS (
SELECT * FROM bt_learning.mz_nba_game_details_partitioned FOR TIMESTAMP AS OF TIMESTAMP '2025-01-08 14:35:18.215 +0100'
),
prod AS (
SELECT * FROM bt_learning.mz_nba_game_details_partitioned
)

SELECT
	CASE WHEN o.player_id IS NULL THEN 'new'
		 WHEN p.player_id IS NULL THEN 'deleted'
		 ELSE 'retained'
	END AS record_change_type,
	COUNT(1)
FROM old o
FULL OUTER JOIN prod p ON o.player_id = p.player_id AND o.game_id = p.game_id
GROUP BY 1
;

--------

-- Query below can be used to check if there are any other branches available in the table
SELECT *
FROM bt_learning."mz_nba_game_details_partitioned$refs"
;

--------

SELECT *
FROM bt_learning."mz_nba_game_details_partitioned$snapshots"
;
-- If we in fact make a mistake and delete something that we don't want to we can simply use query such as the one below to roll back on the version of the table that we need to
CALL system.rollback_to_snapshot(
	table => mz_nba_game_details_partitioned
	snapshot_id => 7909477670147798433
)
;

-- The query above does not work here only due to trino and would work normally in Spark

--------

-- There are some other useful query tips/tricks you can do on Iceberg tables such as the query below

-- Check in what exact file is the current row and when it was added (we can possibly filter on it too)
SELECT
	*,
	"$path",
	"$file_modified_time"
FROM bt_learning.mz_nba_game_details_partitioned
;
