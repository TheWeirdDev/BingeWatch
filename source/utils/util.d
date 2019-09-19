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
