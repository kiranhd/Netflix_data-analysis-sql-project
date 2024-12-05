--Netflix project

CREATE TABLE netflix 
(
   show_id	         VARCHAR(6),
   type              VARCHAR(15),
   title	         VARCHAR(150),
   director	         VARCHAR(220),
   casts	         VARCHAR(1000),
   country	         VARCHAR(150),   
   date_added	     VARCHAR(50),
   release_year	     INT,
   rating	         VARCHAR(10),
   duration          VARCHAR(20),
   listed_in	     VARCHAR(100),
   description       VARCHAR(250)
);

SELECT * from netflix;

SELECT Count(*) as total_content from netflix;

-- 15 Business Problems and Solutions.

-- 1. Count the number of movies and TV shows.
  
    SELECT
	      type,count(*) as total_counts 
	FROM netflix
    GROUP BY type;

-- 2. Find the most common rating for movies and TV shows.
  
  SELECT 
       type,rating 
  FROM 
      ( select type,rating,count(*),
        RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
        from netflix 
        GROUP BY type,rating) as t1 
   WHERE ranking = 1;

-- 3.List all movies released in a specific year (e.g., 2020).

    SELECT *
	FROM netflix
	WHERE type = 'Movie'
	      AND
		  release_year = 2020;
		  
-- 4.Find the top 5 countries with the most content on Netflix.

    SELECT 
	      distinct(UNNEST(STRING_TO_ARRAY(country, ','))) as new_COUNTRY,
		  COUNT(show_id) as Total_Contents
    FROM netflix
	GROUP BY new_COUNTRY
	ORDER BY Total_Contents DESC
	LIMIT 5;
 
-- 5.Identify the longest movie or TV show duration.

   SELECT 
         title,
		 substring(duration, 1,position ('m' in duration)-1)::int as duration
   FROM Netflix
   WHERE type = 'Movie' and duration is not null
   ORDER BY duration Desc
   LIMIT 1;
   
-- 6.Find content added inn the last 5 years.

   SELECT *
   FROM netflix
   WHERE TO_DATE(date_added, 'Month DD,YYYY')>= CURRENT_DATE - INTERVAL '5 years';
         
-- 7.Find all the movies/TV showes by director 'Rajiv Chilaka'!

   SELECT *
   FROM netflix
   WHERE director LIKE '%Rajiv Chilaka%';

-- 8.List all TV shows with more than 5 seasons.

   SELECT *
   FROM netflix
   WHERE type = 'TV Show'
   AND
   SPLIT_PART(duration,' ',1)> '5 sessions' 
   
-- 9.Count the number of content items in each genre.

   SELECT 
         (UNNEST(STRING_TO_ARRAY(listed_in,','))) as genre,
		 COUNT(show_id) as Total_Content
   FROM netflix
   GROUP BY genre;
   
-- 10.Find each year and the average numbers of content release by India on netflix return top 5 year with 
    -- highest average content release !. 
    
	SELECT 
	       EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD,YYYY')) as year,
		   COUNT(*) as Yearly_Content,
		   ROUND(
		   COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country LIKE '%India%')::numeric*100, 
		          2) as avg_content_per_year
	FROM netflix
	WHERE country ILIKE '%India%'
	GROUP BY year
	ORDER BY avg_content_per_year DESC
	LIMIT 5;
	
-- 11.List all movies that are documentaries.

    SELECT *
	FROM netflix
	WHERE
	      type = 'Movie' AND listed_in ILIKE '%documentaries%';
	
-- 12.Find all content without a director.

    SELECT *
	FROM netflix
	WHERE director IS NULL;
	
-- 13.Find how many movies actor 'Salman Khan' appeared in last 10 years !

   SELECT *
   FROM netflix
   WHERE  casts ILIKE '%salman khan%' 
          AND 
          release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
		  
-- 14.Find the top 10 actors who have appeared in the highest number of movies prooduced in India.

   SELECT 
         UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
		 COUNT(*) as total_number_of_movies
   FROM netflix
   WHERE country ILIKE '%india%'
   GROUP BY actors
   ORDER BY total_number_of_movies DESC
   LIMIT 10;
   
-- 15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. 
--    Label content containing these keywords as 'Bad' and all other content as 'Good'.
--    also count how many items fall into each category.

WITH new_table 
  AS (  SELECT *,
	          CASE 
			  WHEN
			      description ILIKE '%kill%' 
				  OR
				  description ILIKE '%violence%' THEN 'Bad_Content'
				  ELSE 'Good_Content'
			  END as category
	FROM netflix )
 SELECT
       category,
	   COUNT(*) as total_content 
FROM new_table
GROUP BY category ;
       
