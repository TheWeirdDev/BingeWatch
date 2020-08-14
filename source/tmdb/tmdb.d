module tmdb.tmdb;

import std.process;
import std.json, std.conv, std.format;
import std.algorithm, std.range, std.string;
import std.uri;
import core.time;
import requests;
import db.models;
import std.exception;

static import config;

class TMDB {
private:
    static immutable(string) apiKey;
    static pragma(inline, true) string makeUrl(string s, string query = "") {
        enum apiUrl = "https://api.themoviedb.org/3/%s?%sapi_key=%s&language=en-US";
        return format!apiUrl(s, query, apiKey);
    }

public:
    shared static this() {
        apiKey = config.API_KEY;
        if (apiKey != "")
            return;
        // debug apiKey = environment.get("API_KEY", "");
        debug apiKey = import(".env");
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
        const url = makeUrl("search/tv", format!"query=%s&page=1&"(name.encode));
        const content = getRequest(url);
        const resp = parseJSON(content);
        if (resp["total_results"].integer == 0) {
            throw new Exception("No metadata found for '" ~ name ~ "'");
        }
        return cast(ulong) resp["results"].array[0]["id"].integer;
    }

    ulong searchMovie(in string name) {
        const url = makeUrl("search/movie",
                format!"query=%s&page=1&include_adult=true&"(name.encode));
        const content = getRequest(url);
        const resp = parseJSON(content);
        const count = resp["total_results"].integer;
        if (count == 0) {
            throw new Exception("No metadata found for '" ~ name ~ "'");
        } else if (count > 1) {
            import std.array : array;

            auto x = resp["results"].array.filter!(a => a["title"].str == name)();
            if (x.array.length > 0) {
                return x.array[0]["id"].integer;
            }
        }
        return cast(ulong) resp["results"].array[0]["id"].integer;
    }

    auto getSeason(ulong id, long snum) {
        const url = makeUrl(format!"tv/%d/season/%d"(id, snum));
        const content = getRequest(url);
        return parseJSON(content);
    }

    auto getTVShow(in ulong id) {
        const url = makeUrl(format!"tv/%d"(id));
        const content = getRequest(url);
        const resp = parseJSON(content);
        auto tvs = new TVShow;

        tvs.name = resp["name"].str;
        tvs.tmdb_id = resp["id"].integer;
        tvs.description = resp["overview"].str;
        tvs.rating = resp["vote_average"].floating;
        const t = resp["episode_run_time"].array;
        if (t.length > 0)
            tvs.episode_length = t[0].integer;

        tvs.genres = resp["genres"].array
            .map!((item) { return item["name"].str; })
            .to!string;

        tvs.creators = resp["created_by"].array
            .map!((item) { return item["name"].str; })
            .to!string;

        const fad = resp["first_air_date"].str;
        tvs.year = fad[0 .. fad.indexOf("-")].to!int;

        tvs.cover_picture = resp["backdrop_path"].str;
        tvs.picture = resp["poster_path"].str;
        tvs.episode_count = resp["number_of_episodes"].integer;
        tvs.season_count = resp["number_of_seasons"].integer;

        return tvs;
    }

    auto getMovie(in ulong id) {
        const url = makeUrl(format!"movie/%d"(id), "&append_to_response=release_dates&");
        const content = getRequest(url);
        const resp = parseJSON(content);
        auto m = new Movie;
        m.name = resp["title"].str;
        m.tmdb_id = resp["id"].integer;
        m.description = resp["overview"].str;
        m.rating = resp["vote_average"].floating;
        m.genres = resp["genres"].array
            .map!((item) { return item["name"].str; })
            .to!string;

        const rd = resp["release_date"].str;
        m.year = rd[0 .. rd.indexOf("-")].to!int;

        m.cover_picture = resp["backdrop_path"].str;
        m.picture = resp["poster_path"].str;
        m.imdb_id = resp["imdb_id"].str;
        m.length = resp["runtime"].integer;
        m.age_rating = resp["release_dates"]["results"].array.filter!(
                item => item["iso_3166_1"].str == "US").array[0]["release_dates"]
            .array[0]["certification"].to!string;

        return m;
    }

}

unittest {
    import config;
    import db.models;
    import std.stdio : writeln;

    writeln("Running api tests:");

    TVShow ppd = TMDB.getTVShow(81983);
    assert(ppd.name == "Paradise PD");
    writeln(ppd.genres);

    auto a = TMDB.getSeason(1668, 2);
}
