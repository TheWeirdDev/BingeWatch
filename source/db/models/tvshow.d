module db.models.tvshow;

import db.models.episode;
import hibernated.annotations;

@Table("shows")
class TVShow {
    @Generated @Id long id;
    long tmdb_id;
    string cover_picture = "";
    string picture = "";
    string name;
    string dir_path;
    string creators = "[]";
    string quality = ""; //TODO
    string description = "";
    string genres = "[]";
    Episode[] episodes; //TODO
    long episode_length = 0;
    long episode_count = 0;
    long season_count = 0;
    long year;
    double rating = 0;
}
