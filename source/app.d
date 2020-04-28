module main;
import hibernated.core;
import std.algorithm;
import ui.main_window;
import gtk.Main;
import std.stdio;
import core.thread;
import utils.util;
import gtk.Application, gtk.ApplicationWindow;

/**
    The XInitThreads function initializes Xlib support for concurrent threads.
    This function must be the first Xlib function a multi-threaded program calls,
    and it must complete before any other Xlib call is made.
    This function returns a nonzero status if initialization was successful; otherwise, it returns zero.
    On systems that do not support threads,this function always returns zero.
*/
extern (C) int XInitThreads();
private enum X11NoThreadError = 0;

int main(string[] args) {
    if (XInitThreads() == X11NoThreadError) {
        stderr.writeln("The X11 system does not support threads.");
        return 1;
    }
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

    return app.run(args);
}
