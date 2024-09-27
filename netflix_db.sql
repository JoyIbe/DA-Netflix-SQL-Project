--
CREATE TABLE netflix
(
	show_id	VARCHAR(5),
	type    VARCHAR(10),
	title	VARCHAR(250),
	director VARCHAR(550),
	casts	VARCHAR(1050),
	country	VARCHAR(550),
	date_added	VARCHAR(55),
	release_year	INT,
	rating	VARCHAR(15),
	duration	VARCHAR(15),
	listed_in	VARCHAR(250),
	description VARCHAR(550)
);

SELECT * FROM netflix;

-- 15 Business Problems Statements and their Solutions

--1. Count the number of Movies vs TV Shows
SELECT DISTINCT type,
COUNT(*)
FROM netflix
GROUP BY 1;

--2. Find the most common rating for movies and TV shows
SELECT type, rating
FROM
(
SELECT type, rating,
COUNT (*),
RANK() OVER (PARTITION BY type ORDER BY COUNT (*) DESC) AS rank
FROM netflix
GROUP BY 1,2
ORDER BY 1,3 DESC 
)  as most_common_rating
WHERE rank = 1

--3. List all movies released 2021
SELECT * 
FROM netflix
WHERE type = 'Movie' AND release_year = 2021;

--4. Find the top 5 countries with the most content on Netflix
SELECT 
UNNEST(STRING_TO_ARRAY(country, ',')) new_country,
COUNT (show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

--5. Identify the longest movie
SELECT *
FROM netflix
WHERE type = 'Movie' AND
duration =(SELECT MAX(duration) FROM netflix);

--6. Find content added in the last 5 years
SELECT * 
FROM netflix 
WHERE date_added >= current_date - interval '5years'; 

7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

--8. List all TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE type = 'TV Show'
AND SPLIT_PART(duration, ' ', 1)::INT > 5;

--9. Count the number of content items in each genre
SELECT 
UNNEST(STRING_TO_ARRAY(listed_in, ',')) genre,
COUNT (show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;

--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!
--By date_added
SELECT 
EXTRACT(YEAR FROM date_added)  as years,
COUNT(*) as yearly_content,
ROUND(COUNT(*)::numeric/
(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100 ,2)
as avg_release
FROM netflix
WHERE country = 'India' 
GROUP BY 1
ORDER BY avg_release DESC 
LIMIT 5;

--11. List all movies that are documentaries
SELECT * 
FROM netflix
WHERE listed_in ILIKE '%documentaries%';

--12. Find all content without a director
SELECT *
FROM netflix
WHERE director IS NULL

--13. Find how many movies actor 'Ryan Reynolds' appeared in last 10 years!
SELECT * 
FROM netflix
WHERE casts ILIKE '%Ryan Reynolds%'
AND release_year > EXTRACT(YEAR FROM Current_Date) - 10;

--14. Find the top 10 actors who have appeared in the highest number of movies produced in United States.
SELECT 
UNNEST(STRING_TO_ARRAY(casts, ',')) actors,
COUNT (*) total_content
FROM netflix
WHERE country LIKE '%United States%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.
WITH new_table AS(
SELECT *,
CASE 
	WHEN description ILIKE '%kill%'
	OR description ILIKE '%violen%' THEN 'Bad' 
	ELSE 'Good'
END category
FROM netflix
)
SELECT category,
COUNT (*) total_content
FROM new_table
GROUP BY 1

