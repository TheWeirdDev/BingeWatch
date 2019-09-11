module main;
import hibernated.core;
import std.algorithm;
import ui.main_window;
import gtk.Main;
import std.stdio;
import core.thread;
import utils.util;

int main(string[] args) {

    Main.init(args);
    createConfigDirIfNotExists();

    auto mw = new MainWindow();
    mw.show();

    Main.run();

    return 0;
}
