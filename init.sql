CREATE DATABASE imdb;

\c imdb

CREATE TABLE IF NOT EXISTS title_basics (
    tconst VARCHAR PRIMARY KEY,
    titleType VARCHAR,
    primaryTitle VARCHAR,
    originalTitle VARCHAR,
    isAdult INT,
    startYear INT,
    endYear INT,
    runtimeMinutes INT,
    genres VARCHAR
);

CREATE TABLE IF NOT EXISTS title_principals (
    tconst VARCHAR REFERENCES title_basics(tconst),
    ordering INT,
    nconst VARCHAR,
    category VARCHAR,
    job VARCHAR,
    characters VARCHAR
);

CREATE TABLE IF NOT EXISTS name_basics (
    nconst VARCHAR PRIMARY KEY,
    primaryName VARCHAR,
    birthYear INT,
    deathYear INT,
    primaryProfession VARCHAR,
    knownForTitles VARCHAR
);

CREATE TABLE IF NOT EXISTS title_ratings (
    tconst VARCHAR PRIMARY KEY REFERENCES title_basics(tconst),
    averageRating DECIMAL,
    numVotes INT
);

CREATE TABLE IF NOT EXISTS bacon_numbers (
    nconst VARCHAR REFERENCES name_basics(nconst),
    bacon_number INT,
    year_achieved INT,
    tconst VARCHAR
);

CREATE TABLE IF NOT EXISTS bacon_numbers (
    nconst VARCHAR REFERENCES name_basics(nconst),
    bacon_number INT,
    year_achieved INT,
    tconst VARCHAR
);

CREATE OR REPLACE FUNCTION calculate_bacon_number() RETURNS VOID AS $$
DECLARE
  actor record;
  year INT;
  current_bacon_number INT;
BEGIN
  -- Initialize bacon_number table for Kevin Bacon
  INSERT INTO bacon_numbers (nconst, bacon_number, year_achieved, tconst) VALUES ('nm0000102', 0, NULL, NULL);
  
  -- Set the starting year to 1978
  year := 1978;
  
  -- Calculate bacon number year by year
  WHILE year <= (SELECT MAX(startYear) FROM title_basics WHERE startYear IS NOT NULL) LOOP
    -- Iterate over each actor
    FOR actor IN (SELECT DISTINCT nconst FROM name_basics) LOOP
      -- Calculate the minimum bacon number for the current actor in the current year
      SELECT MIN(bn.bacon_number + 1)
      INTO current_bacon_number
      FROM title_principals tp1
      JOIN title_basics tb1 ON tp1.tconst = tb1.tconst
      JOIN title_principals tp2 ON tb1.tconst = tp2.tconst AND tp1.nconst != tp2.nconst
      JOIN bacon_numbers bn ON tp2.nconst = bn.nconst
      WHERE tp1.nconst = actor.nconst AND tb1.startYear <= year AND bn.year_achieved <= year;
      
      -- If the bacon number improved, add it to the bacon_number table
      IF current_bacon_number < (SELECT MIN(bacon_number) FROM bacon_numbers WHERE nconst = actor.nconst) THEN
        INSERT INTO bacon_numbers (nconst, bacon_number, year_achieved, tconst)
        VALUES (actor.nconst, current_bacon_number, year, (SELECT tconst FROM title_principals WHERE nconst = actor.nconst LIMIT 1));
      END IF;
    END LOOP;
    
    -- Move to the next year
    year := year + 1;
  END LOOP;
END;
$$ LANGUAGE plpgsql;
