module db.models.episode;

import db.models.tvshow;
import hibernated.annotations;

@Table("episode")
class Episode {
    @Generated @Id int id;
    int num;
    int season;
    TVShow tvshow;
    string name;
}
