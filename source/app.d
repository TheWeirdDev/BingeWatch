module main;
import hibernated.core;
import std.algorithm;
import ui.main_window;
import gtk.Main;
import std.stdio;
import core.thread;
import utils.util;
import gtk.Application, gtk.ApplicationWindow;

int main(string[] args) {
    ApplicationWindow win;
    auto app = new Application("com.theweirddev.bingewatch", GApplicationFlags.FLAGS_NONE);
    app.addOnActivate((Application) {
        win = new ApplicationWindow(app);
        win.addOnDelete((Event, Widget) { app.quit(); return true; });
        auto mw = new MainWindow();
        mw.show(win);
    });

    createConfigDirIfNotExists();

    app.run(args);

    return 0;
}
