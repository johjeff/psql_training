CREATE TABLE query1 AS
    SELECT genres.name, COUNT(hasagenre.genreid) FROM genres, hasagenre WHERE genres.genreid = hasagenre.genreid GROUP BY genres.name;

CREATE TABLE query2 AS
    SELECT genres.name, AVG(ratings.rating) as rating FROM genres, hasagenre, ratings WHERE hasagenre.movieid = ratings.movieid GROUP BY genres.name;
    # Fix it - returns each genre, but average is for ALL ratings not just for genre