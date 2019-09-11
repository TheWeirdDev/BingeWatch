module db.models.movie;

import hibernated.annotations;
import std.parallelism;

@Table("movies")
class Movie {
	@Generated @Id long id;
	long tmdb_id;
	long imdb_id;
	string name;
	string file_path;
	string creators;
	string quality;
	string description;
	string genres;
	long year;
	string age_rating;
	float rating;
	long length;
}
