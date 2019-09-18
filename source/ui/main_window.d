module ui.main_window;
import std.stdio;
import std.file;
import std.string;
import std.concurrency;
import core.time;
import ui.gtkall;
import ui.widgets.welcome;
import ui.widgets.shelf;
import db.library;
import db.models;
import vlcd;
import tmdb.tmdb;
import tmdb.metadata;

class MainWindow {

private:
    Builder builder;
    Window w;
    Stack mainStack;
    InfoBar infobar;
    Timeout infoTimeout;
    Label message;
    Box videosBox;
    Box contents;
    Vlc v;
    Library lib;

public:
    this() {
        builder = new Builder();
        builder.addFromResource("/com/theweirddev/bingewatch/data/main_window.ui");
        lib = new Library;
    }

    void show() {
        w = cast(Window) builder.getObject("window");
        w.addOnDelete(delegate(Event, Widget) {
            //   v.stop();
            Main.quit();
            return true;
        });

        // Button b = cast(Button) builder.getObject("btn");
        // b.addOnClicked((Button) { v.play(); });

        // Button sub = cast(Button) builder.getObject("sub");
        // sub.addOnClicked((Button) {});

        // DrawingArea player = cast(DrawingArea) builder.getObject("player");

        //Box playerBox = cast(Box) builder.getObject("box_player");
        // Button next = cast(Button) builder.getObject("btn_next");
        mainStack = cast(Stack) builder.getObject("main_stack");
        videosBox = cast(Box) builder.getObject("box_videos");
        infobar = cast(InfoBar) builder.getObject("infobar");
        message = new Label("");
        infobar.getContentArea().add(message);
        //infobar.addButton("Close", ResponseType.CLOSE);
        infobar.setRevealed(false);
        infobar.addOnResponse((int resp, InfoBar ifb) {
            if (cast(ResponseType) resp == ResponseType.CLOSE) {
                ifb.setRevealed(false);
            }
        });
        infobar.setShowCloseButton(true);

        auto styleProvider = new CssProvider();
        styleProvider.loadFromData(`
            .title_label {font: 2.2rem raleway;}
            .sub_label {font-size:1.6rem;}
            .button_title {font-size:1.3rem;}
            .button_sub {font-size:1.05rem;}
        `);

        StyleContext.addProviderForScreen(Screen.getDefault(), styleProvider,
                STYLE_PROVIDER_PRIORITY_APPLICATION);

        Button back = cast(Button) builder.getObject("btn_back");
        back.setSensitive(false);
        back.addOnClicked((Button) { mainStack.setVisibleChildName("main_page"); });

        mainStack.addOnNotify((ParamSpec, ObjectG) {
            back.setSensitive(mainStack.getVisibleChildName() != "main_page");
        }, "visible-child");

        contents = new Box(GtkOrientation.VERTICAL, 5);
        contents.setHexpand(true);
        contents.setVexpand(true);
        videosBox.add(contents);
        reloadLibary();

        // next.addOnClicked(delegate(Button b) {
        //     stack.setVisibleChildName("player_box");
        // });
        w.setSizeRequest(750, 550);
        w.showAll();
        //     v = new Vlc(getXid(w.getWindow()));
        //     player.modifyBg(GtkStateType.NORMAL, new Color(0, 0, 0));
        //    // w.modifyBg(GtkStateType.NORMAL, new Color(0, 0, 0));
        //     playerBox.modifyBg(GtkStateType.NORMAL, new Color(0, 0, 0));
        //     player.setEvents(GdkEventMask.EXPOSURE_MASK |
        //     GdkEventMask.LEAVE_NOTIFY_MASK | GdkEventMask.BUTTON_PRESS_MASK | GdkEventMask.POINTER_MOTION_MASK|
        //     GdkEventMask.POINTER_MOTION_HINT_MASK);
        // addondamage???
        //     player.addOnEvent((Event, Widget w) {
        //         //x, y, w, h = widget.allocation
        //         GtkAllocation alloc;
        //         auto cr = createContext(w.getWindow());
        //         w.getAllocation(alloc);
        //         cr.rectangle(0, 0, alloc.width, alloc.height);
        //         cr.setSourceRgb(0, 0, 0);
        //         cr.fill();
        //         return true;
        //     });
        //     v.setMediaPath("/home/alireza/Downloads/Fleabag.S02E06.720p.WEB.DL.HEVC.x265.RMT.Farda.DL.mkv");

    }

    ~this() {

    }

    void showMessage(string text, GtkMessageType msgType = GtkMessageType.INFO) {
        message.setText(text);
        infobar.setMessageType(msgType);
        infobar.setRevealed(true);
        if (infoTimeout !is null) {
            infoTimeout.stop();
        }
        infoTimeout = new Timeout({ infobar.setRevealed(false); return false; }, 5, false);
    }

    void reloadLibary() {
        if (auto t = contents.getChildren()) {
            foreach (ref w; t.toArray!Widget()) {
                contents.remove(w);
            }
        }
        if (lib.isEmpty()) {
            auto welcome = new Welcome("Your Media Collection is Empty",
                    "Add your movies and tv shows");
            auto i = new Image();
            i.setFromIconName("gtk-add", GtkIconSize.LARGE_TOOLBAR);
            welcome.addButton("Add a movie", "Import a movie into your collection", i, (Button b) {
                mainStack.setVisibleChildName("player_page");

                //addMovie();
            });
            auto i2 = new Image();
            i2.setFromIconName("gtk-add", GtkIconSize.LARGE_TOOLBAR);
            welcome.addButton("Add a tv show",
                    "Import a tv show or series into your collection", i2, (Button b) {
                importTVShow();
            });
            contents.packStart(welcome, true, true, 0);
        } else {
            auto s = new ScrolledWindow();
            s.add(new Shelf(lib));
            contents.packStart(s, true, true, 0);
        }
        contents.showAll();
    }

    void importTVShow() {
        auto name = "";
        debug {
            auto dir = "/run/media/alireza/Movies/Khareji/Serial/Friends/";
            name = "Friends";
        } else {
            auto dir = selectTVShowDir(name);
        }
        if (dir == "" || name == "") {
            return;
        }
        //TODO: Check if this show already exists
        auto tvs = lib.addTVShow(name, dir);
        showMessage("Downloading metadata");

        loadMetadataFor(tvs, (TVShow tv, Exception e) {
            if (e !is null) {
                showMessage("Error: " ~ e.msg, GtkMessageType.ERROR);
                return;
            }
            lib.update(tv);
            reloadLibary();
            showMessage("Done");
        });
    }

    string selectTVShowDir(out string name) {
        auto fcd = new FileChooserDialog("Select your TVShow directory", w, FileChooserAction.SELECT_FOLDER,
                ["Select", "Cancel"], [ResponseType.ACCEPT, ResponseType.CANCEL]);
        auto res = fcd.run();
        auto dir = "";
        {
            scope (exit)
                fcd.destroy();
            if (res != ResponseType.ACCEPT) {
                return "";
            }
            dir = fcd.getFilename();
        }
        if (!exists(dir) || !isDir(dir)) {
            return "";
        }
        name = dir[dir.lastIndexOf("/") + 1 .. $];

        auto d = new Dialog("Import", w, GtkDialogFlags.MODAL, [
                "Cancel", "Import"
                ], [ResponseType.CANCEL, ResponseType.ACCEPT]);
        auto box = new Box(GtkOrientation.VERTICAL, 5);
        box.setMargin(10);
        auto box2 = new Box(GtkOrientation.HORIZONTAL, 5);
        box2.setHexpand(true);

        auto lbl = new Label("TVShow name:");
        box2.add(lbl);

        auto ent = new Entry(name);
        ent.setHexpand(true);
        ent.addOnChanged((EditableIF) { name = ent.getText(); });
        box2.add(ent);

        box.add(box2);

        d.getContentArea().add(box);
        d.showAll();
        res = d.run();
        scope (exit)
            d.destroy();
        if (res != ResponseType.ACCEPT) {
            return "";
        }
        return dir;
    }

}
