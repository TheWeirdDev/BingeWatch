module tmdb.metadata;

import core.thread;
import std.traits;
import std.stdio;

import db.models;
import tmdb.tmdb;

alias TVShowCallback = void delegate(TVShow, Exception);

private class TVShowMetadataDownloader : Thread {
    string name;
    TVShowCallback cb;

    this(string name, TVShowCallback callback) {
        this.name = name;
        cb = callback;
        super(&run);
    }

    void run() {
        try {
            auto tmdbid = TMDB.searchTVShow(this.name);
            if (tmdbid == -1) {
                throw new Exception("No metadata found for '" ~ name ~ "'");
            }
            auto tv = TMDB.getTVShow(tmdbid);
            cb(tv, null);
        } catch (Exception e) {
            cb(null, e);
        }
    }
}

void loadMetadataFor(string name, TVShowCallback callback) {
    auto thread1 = new TVShowMetadataDownloader(name, callback);
    thread1.start();
}
