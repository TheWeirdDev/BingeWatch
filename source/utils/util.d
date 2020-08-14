module utils.util;
import std.path;
import std.file;

pragma(inline, true) {
    static string getUserHomeDir() {
        return expandTilde("~");
    }

    static string getConfigDirName() {
        return getUserHomeDir() ~ "/.config/BingeWatch/";
    }

    static string getImagesDirName() {
        return getConfigDirName() ~ "images";
    }

    static string getImageUrl(string path) {
        return "https://image.tmdb.org/t/p/w780" ~ path;
    }
}

import std.format;

string durationToString(long milliseconds) {
    if (milliseconds < 1000) {
        return "00:00:00";
    }
    auto seconds = milliseconds / 1000;
    // const seconds = milliseconds / 1000 / 60 % 60;
    const minutes = seconds / 60 % 60;
    const hours = seconds / 60 / 60;
    seconds %= 60;

    string res = "";
    if (hours > 0) {
        res ~= format!"%02d:"(hours);
    }
    res ~= format!"%02d:%02d"(minutes, seconds);
    return res;
}

static void createConfigDirIfNotExists() {
    auto cfgDir = getConfigDirName();
    if (!exists(cfgDir)) {
        mkdirRecurse(cfgDir);
    } else if (!isDir(cfgDir)) {
        remove(cfgDir);
        mkdirRecurse(cfgDir);
    }
    auto imgDir = getImagesDirName();
    if (!exists(imgDir))
        mkdir(imgDir);
}
