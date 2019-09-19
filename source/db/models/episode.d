module db.models.episode;

import db.models.tvshow;
import hibernated.annotations;

@Table("episode")
class Episode {
    @Generated @Id long id;
    string name;
    string file_path;
    string description = "";
    double rating = 0;
    string picture_path = "";
    long num = 0;
    long season = 0;
    long watched = 0;
    long length = 0;
    TVShow tvshow;
}
