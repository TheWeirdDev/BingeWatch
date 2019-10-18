module db.library;

import db.models;
import db.database;
import tmdb.tmdb;

class Library {
private:
    TVShow[] shows;
    Movie[] movies;
    Database ds;

    void reload() {
        movies = ds.getMovies();
        shows = ds.getShows();
    }

public:
    this() {
        ds = Database.getInstance();
        reload();
    }

    ref Movie[] getMovies() {
        reload();
        return movies;
    }

    ref TVShow[] getShows() {
        reload();
        return shows;
    }

    bool isEmpty() {
        return !(shows.length || movies.length);
    }

    void update(TVShow tvs) {
        ds.updateItem(tvs);
        reload();
    }

    void update(Movie m) {
        ds.updateItem(m);
        reload();
    }

    void add(Movie m) {
        ds.addItem(m);
        reload();
    }

    void add(TVShow tvs) {
        ds.addItem(tvs);
        reload();
    }

    TVShow addTVShow(string name, string path) {
        TVShow tvs = new TVShow;
        tvs.name = name;
        tvs.dir_path = path;
        add(tvs);
        return tvs;
    }

    Movie addMovie(string name, string file) {
        Movie m = new Movie;
        m.name = name;
        m.file_path = file;
        add(m);
        return m;
    }

}
