module tmdb.tmdb;

import std.process;
import std.json, std.conv, std.format;
import std.algorithm, std.range, std.string;
import std.uri;
import core.time;
import requests;
import db.models;
import std.exception;

import config;

class TMDB {
private:
    static immutable(string) apiKey;
    static pragma(inline, true) string makeUrl(string s, string query = "") {
        enum apiUrl = "https://api.themoviedb.org/3/%s?%sapi_key=%s&language=en-US";
        return format!apiUrl(s, query, apiKey);
    }

public:
    shared static this() {
        apiKey = API_KEY;
        if (apiKey != "")
            return;
        debug apiKey = environment.get("API_KEY", "");
        enforce(apiKey != "", "No api key specified");
    }

static:
    auto getRequest(string url) {
        auto req = Request();
        req.timeout = 10.seconds;
        req.keepAlive = false;
        return req.get(url).responseBody.toString();
    }

static:

    ulong searchTVShow(in string name) {
        auto url = makeUrl("search/tv", format!"query=%s&page=1&"(name.encode));
        auto content = getRequest(url);
        auto resp = parseJSON(content);
        if (resp["total_results"].integer == 0) {
            throw new Exception("No metadata found for '" ~ name ~ "'");
        }
        return cast(ulong) resp["results"].array[0]["id"].integer;
    }

    ulong searchMovie(in string name) {
        auto url = makeUrl("search/movie",
                format!"query=%s&page=1&include_adult=true&"(name.encode));
        auto content = getRequest(url);
        auto resp = parseJSON(content);
        if (resp["total_results"].integer == 0) {
            throw new Exception("No metadata found for '" ~ name ~ "'");
        }
        return cast(ulong) resp["results"].array[0]["id"].integer;
    }

    auto getSeason(ulong id, long snum) {
        auto url = makeUrl(format!"tv/%d/season/%d"(id, snum));
        auto content = getRequest(url);
        return parseJSON(content);
    }

    TVShow getTVShow(in ulong id) {
        auto url = makeUrl(format!"tv/%d"(id));
        auto content = getRequest(url);
        auto resp = parseJSON(content);
        auto tvs = new TVShow;
        try {
            tvs.name = resp["name"].str;
            tvs.tmdb_id = resp["id"].integer;
            tvs.description = resp["overview"].str;
            tvs.rating = resp["vote_average"].floating;
            auto t = resp["episode_run_time"].array;
            if (t.length > 0)
                tvs.episode_length = t[0].integer;

            tvs.genres = resp["genres"].array
                .map!((item) { return item["name"].str; })
                .to!string;

            tvs.creators = resp["created_by"].array
                .map!((item) { return item["name"].str; })
                .to!string;

            auto fad = resp["first_air_date"].str;
            tvs.year = fad[0 .. fad.indexOf("-")].to!int;

            tvs.cover_picture = resp["backdrop_path"].str;
            tvs.picture = resp["poster_path"].str;
            tvs.episode_count = resp["number_of_episodes"].integer;
            tvs.season_count = resp["number_of_seasons"].integer;
        } catch (Exception e) {
            throw new Exception("Failed to load matadata: " ~ e.msg);
        }
        return tvs;
    }

    Movie getMovie(in ulong id) {
        auto url = makeUrl(format!"movie/%d"(id), "&append_to_response=release_dates&");
        auto content = getRequest(url);
        auto resp = parseJSON(content);
        auto m = new Movie;
        try {
            m.name = resp["title"].str;
            m.tmdb_id = resp["id"].integer;
            m.description = resp["overview"].str;
            m.rating = resp["vote_average"].floating;
            m.genres = resp["genres"].array
                .map!((item) { return item["name"].str; })
                .to!string;

            auto rd = resp["release_date"].str;
            m.year = rd[0 .. rd.indexOf("-")].to!int;

            m.cover_picture = resp["backdrop_path"].str;
            m.picture = resp["poster_path"].str;
            m.imdb_id = resp["imdb_id"].str;
            m.length = resp["runtime"].integer;
            m.age_rating = resp["release_dates"]["results"].array.filter!(
                    item => item["iso_3166_1"].str == "US").array[0]["release_dates"]
                .array[0]["certification"].to!string;

        } catch (Exception e) {
            throw new Exception("Failed to load matadata: " ~ e.msg);
        }
        return m;
    }

}
