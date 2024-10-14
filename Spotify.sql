-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);

--Manually written code to import Datas in to the PSQL
COPY public.spotify (artist, track, album, album_type, danceability, energy, loudness, speechiness, acousticness, instrumentalness, liveness, valence, tempo, duration_min, title, channel, views, likes, comments, licensed, official_video, stream, energy_liveness, most_played_on)
FROM 'E:\SQL\Project Spotify\cleaned_dataset.csv'
DELIMITER ','
CSV HEADER;



--EDA 

SELECT *
FROM spotify

DELETE FROM spotify
WHERE duration_min = 0

SELECT DISTINCT channel
FROM spotify

--Easy Level
--1.Retrieve the names of all tracks that have more than 1 billion streams.
SELECT *
FROM spotify
WHERE stream > 100000000

--2.List all albums along with their respective artists.
SELECT 
		artist,
		album
FROM spotify
GROUP BY 1,2


--3.Get the total number of comments for tracks where licensed = TRUE.
SELECT 
		SUM(comments) as Total_comments
FROM spotify
WHERE licensed = 'true'

--4.Find all tracks that belong to the album type single.
SELECT *
FROM spotify
WHERE album_type = 'single'

--5.Count the total number of tracks by each artist.
SELECT 
		artist,
		COUNT(*) as Total_no_Songs
FROM spotify
GROUP BY artist

--Medium Level
--1.Calculate the average danceability of tracks in each album.
SELECT 
		album,
		AVG(danceability)
FROM spotify
GROUP BY 1

--2.Find the top 5 tracks with the highest energy values.
SELECT 
		track,
		AVG(energy)
FROM spotify
GROUP BY 1 
ORDER BY 2 DESC
LIMIT 5

--3.List all tracks along with their views and likes where official_video = TRUE.
SELECT 
		track,
		SUM(views) AS Total_Views,
		SUM(likes) AS Total_Likes
FROM spotify
WHERE official_video = 'true'
GROUP BY 1 
ORDER BY 2 DESC


--4.For each album, calculate the total views of all associated tracks.
SELECT 
		album,
		track,
		SUM(views)
FROM spotify
GROUP BY 1,2
ORDER BY 2 DESC

--5.Retrieve the track names that have been streamed on Spotify more than YouTube.

SELECT *
FROM 
(SELECT 
		track,
		-- most_played_on
		COALESCE(SUM (CASE WHEN most_played_on = 'Youtube' THEN stream END),0) as Youtube,
		--COALESCE to convert null value in to 0
		COALESCE(SUM (CASE WHEN most_played_on = 'Spotify' THEN stream END),0) as Spotify
FROM spotify
GROUP BY 1
) as t1
WHERE 
		Spotify > Youtube
		AND
		Youtube <> 0


--Advanced Level

--1.Find the top 3 most-viewed tracks for each artist using window functions.
SELECT *
FROM
(SELECT 
		artist,
		track,
		SUM(views),
		DENSE_RANK () OVER (PARTITION BY artist ORDER BY SUM(views)DESC) AS Rank
FROM spotify
GROUP BY 1,2
ORDER BY 1,3 DESC) AS t1
WHERE 
		Rank <= 3


--2. Write a query to find tracks where the liveness score is above the average.
SELECT *
FROM spotify
WHERE liveness > (SELECT AVG(liveness) FROM spotify)

--3.Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.
WITH cte
AS
(SELECT 
		album,
		MAX(energy) AS Highest_energy,
		MIN(energy) AS Lowest_energy
FROM spotify
GROUP BY 1
)
SELECT 
		album,
		Highest_energy - Lowest_energy AS Energy_Diff
FROM cte
ORDER BY 2 DESC









