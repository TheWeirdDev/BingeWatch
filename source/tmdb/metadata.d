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

private class TVShowMetadataDownloader : Thread {
private:
    TVShow tv;
    TVShowCallback cb;
    Database ds;

public:

    this(TVShow tv, TVShowCallback callback) {
        super(&run);
        this.ds = Database.getInstance();
        this.tv = tv;
        this.cb = callback;
    }

    void run() {
        try {
            enum reg = ctRegex!("S(\\d\\d?).{0,2}E(\\d\\d?).*\\.(mkv|mp4|wmv|mpg|avi|mpeg)$", "i");
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

            // Remove episodes that don't exist anymore
            foreach (ref old; tv.episodes) {
                foreach (ref ep; newEps) {
                    if (old.file_path == ep.file_path)
                        break;
                }
                ds.removeItem(old);
                //TODO: std.file.remove(old.picture_path);
            }
            foreach (s; seasonsAndEpisodes.keys.sort) {
                //TODO: Download images
                JSONValue season = TMDB.getSeason(tvs.tmdb_id, s);
                auto eps = season["episodes"].array;
                foreach (ref ep; seasonsAndEpisodes[s]) {
                    auto fil = tv.episodes.filter!(e => e.file_path == ep.file_path);
                    if (fil.empty) {
                        ep.name = format("%s S%dE%d", tv.name, ep.season, ep.num);
                        ds.addItem(ep);
                    } else {
                        ep.id = fil.array[0].id;
                        ep.watched = fil.array[0].watched;
                        tv.episodes ~= ep;
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

            cb(tvs, null);
        } catch (Exception e) {
            cb(null, e);
        }
    }
}

void loadMetadataFor(TVShow tvs, TVShowCallback callback) {
    auto thread1 = new TVShowMetadataDownloader(tvs, callback);
    thread1.start();
}
