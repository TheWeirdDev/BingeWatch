module tmdb.metadata;

import core.thread;
import std.stdio;
import std.file, std.regex, std.conv;
import std.algorithm, std.range;
import std.json;

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
            enum reg = ctRegex!("S(\\d\\d?).{0,2}E(\\d\\d?).*\\.(mkv|mp4|wmv|mpg)", "i");
            Episode[][int] seasonsAndEpisodes;
            foreach (string path; dirEntries(tv.dir_path, SpanMode.breadth)) {
                auto m = path.matchFirst(reg);
                if (m.empty)
                    continue;
                int s = m[1].to!int;

                auto ep = new Episode;
                ep.num = m[2].to!int;
                ep.dir_path = path;
                ep.season = s;

                seasonsAndEpisodes[s] ~= ep;
            }

            auto tmdbid = TMDB.searchTVShow(tv.name);
            auto tvs = TMDB.getTVShow(tmdbid);
            tvs.id = tv.id;
            tvs.dir_path = tv.dir_path;

            foreach (s; seasonsAndEpisodes.keys.sort.uniq) {
                JSONValue season = TMDB.getSeason(tv.tmdb_id, s);
                auto eps = season["episodes"].array;
                foreach (ref ep; seasonsAndEpisodes[s]) {
                    auto fil = tv.episodes.filter!(e => e.dir_path == ep.dir_path);
                    if (fil.empty) {
                        ds.addItem(ep);
                    } else {
                        ep.id = fil.array[0].id;
                        ep.watched = fil.array[0].watched;
                        ds.updateItem(ep);
                    }
                    ep.tvshow = tv;

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
