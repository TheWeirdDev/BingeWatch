module utils.util;
import std.path;
import std.file;

static string getUserHomeDir() {
    return expandTilde("~");
}

static string getConfigDirName() {
    return getUserHomeDir() ~ "/.config/BingeWatch/";
}

static void createConfigDirIfNotExists() {
    auto cfgDir = getConfigDirName();
    if (!exists(cfgDir)) {
        mkdirRecurse(cfgDir);
    } else if (!isDir(cfgDir)) {
        remove(cfgDir);
        mkdirRecurse(cfgDir);
    }
}
