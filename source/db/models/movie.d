module db.models.movie;

import hibernated.annotations;
import std.parallelism;

@Table("movies")
class Movie {
	@Generated @Id long id;
	long tmdb_id;
	string imdb_id = "";
	string name;
	string file_path;
	string cover_picture = "";
	string picture = "";
	string quality = "";
	string description = "";
	string genres = "[]";
	long year = 0;
	string age_rating = "";
	double rating = 0.0;
	long length = 0;
	long watched = 0;

	invariant() {
		assert(this.watched <= this.length, "Movie watch time is incorrect");
	}
}
