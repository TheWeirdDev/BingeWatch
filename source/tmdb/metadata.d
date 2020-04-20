module tmdb.metadata;

import core.thread;
import std.stdio;
static import std.file;
import std.regex, std.conv;
import std.algorithm, std.range;
import std.json;
import std.format;
import std.net.curl;

import utils.util;
import db.models;
import db.database;
import tmdb.tmdb;

alias TVShowCallback = void delegate(TVShow, Exception);
alias MovieCallback = void delegate(Movie, Exception);

private class TVShowMetadataDownloader : Thread {
private:
    TVShow tv;
    TVShowCallback callback;
    Database ds;

public:

    this(TVShow tv, TVShowCallback callback) {
        super(&run);
        this.ds = Database.getInstance();
        this.tv = tv;
        this.callback = callback;
    }

    void run() {
        try {
            enum reg = ctRegex!("S(\\d\\d?).{0,2}E(\\d+).*\\.(mkv|mp4|wmv|mpg|avi|mpeg)$", "i");
            Episode[][int] seasonsAndEpisodes;
            Episode[] newEps;
            foreach (string path; std.file.dirEntries(tv.dir_path, std.file.SpanMode.breadth)) {
                auto m = path.matchFirst(reg);
                if (m.empty)
                    continue;
                int s = m[1].to!int;

                auto ep = new Episode;
                ep.num = m[2].to!int;
                ep.file_path = path;
                ep.season = s;

                seasonsAndEpisodes[s] ~= ep;
                newEps ~= ep;
            }

            auto tmdbid = TMDB.searchTVShow(tv.name);
            auto tvs = TMDB.getTVShow(tmdbid);
            tvs.id = tv.id;
            tvs.dir_path = tv.dir_path;
            if (tvs.picture != "")
                download(getImageUrl(tvs.picture), getImagesDirName() ~ tvs.picture);
            if (tvs.cover_picture != "")
                download(getImageUrl(tvs.cover_picture), getImagesDirName() ~ tvs.cover_picture);

            // Remove episodes that don't exist anymore
            foreach (ref old; tv.episodes) {
                if (newEps.filter!(e => e.file_path == old.file_path).empty)
                    ds.removeItem(old);
                //TODO: std.file.remove(old.picture_path);
            }

            foreach (s; seasonsAndEpisodes.keys.sort) {
                JSONValue season = TMDB.getSeason(tvs.tmdb_id, s);
                auto eps = season["episodes"].array;
                foreach (ref ep; seasonsAndEpisodes[s]) {
                    auto fil = tv.episodes.filter!(e => e.file_path == ep.file_path);
                    if (fil.empty) {
                        ep.name = format("%s S%02dE%02d", tv.name, ep.season, ep.num);
                        ds.addItem(ep);
                    } else {
                        ep.id = fil.array[0].id;
                        ep.watched = fil.array[0].watched;
                        //tv.episodes ~= ep;
                    }
                    auto fil2 = eps.filter!(e => e["episode_number"].integer == ep.num);
                    if (!fil2.empty) {
                        auto jsonEp = fil2.array[0];
                        ep.name = jsonEp["overview"].str;
                        ep.description = jsonEp["overview"].str;
                        ep.rating = jsonEp["vote_average"].floating;
                        ep.picture_path = jsonEp["still_path"].str;
                    }
                    ep.tvshow = tv;
                    ds.updateItem(ep);
                    auto dlpath = getImagesDirName() ~ ep.picture_path;
                    if (!std.file.exists(dlpath))
                        download(getImageUrl(ep.picture_path), dlpath);
                }
            }
            callback(tvs, null);
        } catch (Exception e) {
            callback(null, e);
        }
    }
}

private class MovieMetadataDownloader : Thread {
private:
    Movie m;
    MovieCallback callback;
    Database ds;

public:

    this(Movie m, MovieCallback callback) {
        super(&run);
        this.ds = Database.getInstance();
        this.m = m;
        this.callback = callback;
    }

    void run() {
        try {
            auto tmdbid = TMDB.searchMovie(m.name);
            auto movie = TMDB.getMovie(tmdbid);

            movie.id = m.id;
            movie.file_path = m.file_path;
            if (movie.picture != "")
                download(getImageUrl(movie.picture), getImagesDirName() ~ movie.picture);
            if (movie.cover_picture != "")
                download(getImageUrl(movie.cover_picture), getImagesDirName() ~ movie.cover_picture);
            callback(movie, null);
        } catch (Exception e) {
            callback(null, new Exception("Failed to load matadata: " ~ e.msg));
        }

    }
}

void loadMetadataFor(TVShow tvs, TVShowCallback callback) {
    auto tdl = new TVShowMetadataDownloader(tvs, callback);
    tdl.start();
}

void loadMetadataFor(Movie m, MovieCallback callback) {
    auto mdl = new MovieMetadataDownloader(m, callback);
    mdl.start();
}
