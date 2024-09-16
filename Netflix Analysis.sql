-- Netflix Project

DROP TABLE IF EXISTS netflix;

CREATE TABLE netflix
(
	show_id VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(150),
	director VARCHAR(208),
	casts VARCHAR(1000),
	country	VARCHAR(150),
	date_added	VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);


SELECT count(*) as total_content
FROM netflix;

Select DISTINCT type 
FROM netflix;

SELECT * FROM netflix;

-- Business Problems


--- 1. Count the number of Movie vs TV Show

SELECT type, count(*) as total_content
FROM netflix
GROUP BY type


--- 2. 	Find the most common rating for movies and TV Show

SELECT 
	type,
	rating
FROM
(
SELECT 
	type, 
	rating, 
	count(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
FROM netflix
GROUP BY 1,2
-- order by 1, 3 DESC
) as t1
WHERE ranking = 1


--- 3. List all movies released in a specific year (eg: 2020)

SELECT * FROM netflix
where type = 'Movie' AND release_year = 2020


--- 4. Find the top 5 countries with the most content on netflix

select 
	unnest(STRING_TO_ARRAY(country, ',')) as new_country, 
	count(show_id) as Total_content
From netflix
group by 1
order by 2 desc
limit 5


--- 5. Identify the longest movie

select type, duration from netflix
where 
	type = 'Movie'
	AND
	duration = (select max(duration) from netflix)


--- 6. Find content added in the last 5 years

select * from netflix
where TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'


--- 7. Find all the movies/TV Shows by director 'Rajiv Chilaka'!

select * from netflix
where director ILIKE '%RAjiv Chilaka%'


--- 8. List all the TV Shows with more than 5 seasons

select * from netflix
where
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1):: numeric > 5


--- 9. Count the number of content items in each genre

select 
	unnest(STRING_TO_ARRAY(listed_in, ',')) as genre,
	count(show_id) as total_content
from netflix
group by 1


--- 10. Find the each year and the average numbers of content release by India on netflix.
--- return top 5 years with highest avg content release !

select
	EXTRACT(YEAR from TO_DATE(date_added, 'Month DD, YYYY')) as year,
	count(*) as yearly_count,
	ROUND(COUNT(*)::numeric/(select count(*) from netflix where country = 'India')::numeric * 100, 2)
	as avg_content_per_year 
from netflix
where country = 'India'
group by 1


--- 11. List all the movies that are documentaries

select * from netflix
where listed_in ILIKE '%Documentaries%'


--- 12. Find all the content without a director

select * from netflix
where director is NULL


--- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years

select * from netflix
where
	casts ILIKE '%Salman Khan%'
	AND
	release_year > EXTRACT(YEAR from CURRENT_DATE) - 10


--- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India

select 
	unnest(STRING_TO_ARRAY(casts, ',')) as actors,
	count(*) as total_content
from netflix
where country ilike '%india%'
group by 1
order by 2 desc
limit 10


--- 15. Categorize the content based on the presence of the keywords 'Kill' and 'Violence'
--- in the description field. label content containing these keywords as 'Bad' and all other
--- content as 'Good'. Count how many items fall into each category.

WITH contents
AS (
	SELECT 
		* ,
		CASE
		WHEN 
			description ilike '%Kill%' OR
			description ilike '%Violence%' THEN 'Bad Content'
			ELSE
			'Good Content'
		END category
	from netflix
)
select 
	category,
	count(*) as total_content
from contents
group by 1
