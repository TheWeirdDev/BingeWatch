module main;
import hibernated.core;
import std.algorithm;
import ui.main_window;
import gtk.Main;
import std.stdio;
import core.thread;
import utils.util;
import gtk.Application, gtk.ApplicationWindow;

extern (C) int XInitThreads();

int main(string[] args) {
    XInitThreads();
    ApplicationWindow win;
    auto app = new Application("com.theweirddev.bingewatch", GApplicationFlags.FLAGS_NONE);
    app.addOnActivate((Application) {
        win = new ApplicationWindow(app);
        win.setDefaultSize(1000, 600);
        win.addOnDelete((Event, Widget) { app.quit(); return true; });
        auto mw = new MainWindow();
        mw.show(win);
    });

    createConfigDirIfNotExists();

    app.run(args);

    return 0;
}
