# Netflix Movies and TV Shows Data Analysis using SQL (PostgreSQL).

![Netflix logo](https://github.com/kiranhd/Netflix_sql_project/blob/main/Netflix_logo_1.jpg)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL and Dashboard creation using Power BI. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.


## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix 
(
   show_id	    VARCHAR(6),
   type             VARCHAR(15),
   title	    VARCHAR(150),
   director	    VARCHAR(220),
   casts	    VARCHAR(1000),
   country	    VARCHAR(150),   
   date_added	    VARCHAR(50),
   release_year	    INT,
   rating	    VARCHAR(10),
   duration         VARCHAR(20),
   listed_in	    VARCHAR(100),
   description      VARCHAR(250)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT
      type,count(*) as total_counts 
	FROM netflix
    GROUP BY type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
SELECT 
       type,rating 
  FROM 
      ( select type,rating,count(*),
        RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
        from netflix 
        GROUP BY type,rating) as t1 
   WHERE ranking = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT *
	FROM netflix
	WHERE type = 'Movie'
	      AND
		  release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
 SELECT 
       Distinct(UNNEST(STRING_TO_ARRAY(country, ','))) as new_COUNTRY,
		   COUNT(show_id) as Total_Contents
 FROM netflix
 GROUP BY new_COUNTRY
 ORDER BY Total_Contents DESC
 LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT 
      title,
		 substring(duration, 1,position ('m' in duration)-1)::int as duration
   FROM Netflix
   WHERE type = 'Movie' and duration is not null
   ORDER BY duration Desc
   LIMIT 1;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
   SELECT *
   FROM netflix
   WHERE TO_DATE(date_added, 'Month DD,YYYY')>= CURRENT_DATE - INTERVAL '5 years';
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
   SELECT *
   FROM netflix
   WHERE director LIKE '%Rajiv Chilaka%';

```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
   SELECT *
   FROM netflix
   WHERE type = 'TV Show'
   AND
   SPLIT_PART(duration,' ',1)> '5 sessions'
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
   SELECT 
         (UNNEST(STRING_TO_ARRAY(listed_in,','))) as genre,
		 COUNT(show_id) as Total_Content
   FROM netflix
   GROUP BY genre;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
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
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
  SELECT *
	FROM netflix
	WHERE
	      type = 'Movie' AND listed_in ILIKE '%documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
  SELECT *
	FROM netflix
	WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
   SELECT *
   FROM netflix
   WHERE  casts ILIKE '%salman khan%' 
          AND 
          release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
   SELECT 
         UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
		 COUNT(*) as total_number_of_movies
   FROM netflix
   WHERE country ILIKE '%india%'
   GROUP BY actors
   ORDER BY total_number_of_movies DESC
   LIMIT 10;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
WITH new_table 
  AS ( SELECT *,
                CASE 
                    WHEN
                        description ILIKE '%kill%' 
				  OR
                        description ILIKE '%violence%'
                        THEN 'Bad_Content'
                        ELSE 'Good_Content'
                        END as category
	             FROM netflix )
        SELECT
              category,
              COUNT(*) as total_content 
       FROM new_table
       GROUP BY category ;
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Dashboard

![Netflix Dashboard](https://github.com/kiranhd/Netflix_data-analysis-sql-project/blob/main/Dashboard.jpeg)

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.
