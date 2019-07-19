CREATE TABLE users (
	userid SERIAL PRIMARY KEY,
	name CHAR (50)
);

CREATE TABLE movies (
	movieid SERIAL PRIMARY KEY,
	title TEXT
);

CREATE TABLE taginfo (
	tagid SERIAL PRIMARY KEY,
	content TEXT NOT NULL
);

CREATE TABLE genres (
	genreid SERIAL PRIMARY KEY,
	name TEXT
);

CREATE TABLE ratings (
	userid SERIAL REFERENCES users(userid),
	movieid SERIAL REFERENCES movies(movieid),
	rating REAL CHECK (rating <= 5 AND rating >=0),
	timestamp bigint NOT NULL
);

CREATE TABLE tags (
	userid SERIAL REFERENCES users(userid),
	movieid SERIAL REFERENCES movies(movieid),
	tagid SERIAL REFERENCES taginfo(tagid),
	timestamp BIGINT NOT NULL
);

CREATE TABLE hasagenre (
	movieid SERIAL REFERENCES movies(movieid),
	genreid SERIAL REFERENCES genres(genreid)
);
