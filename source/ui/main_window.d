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
import tmdb.tmdb;
import tmdb.metadata;

class MainWindow {

private:
    Builder builder;
    ApplicationWindow w;
    Stack mainStack;
    InfoBar infobar;
    HeaderBar header;
    ButtonBox headerbtns;
    Timeout infoTimeout;
    Label message;
    Box videosBox;
    Box contents;
    Library lib;

public:
    this() {
        builder = new Builder();
        builder.addFromResource("/com/theweirddev/bingewatch/data/main_window.ui");
        lib = new Library;
    }

    void show() {
        w = cast(ApplicationWindow) builder.getObject("window");
        w.addOnDelete(delegate(Event, Widget) {
            //   v.stop();
            Main.quit();
            return true;
        });

        mainStack = cast(Stack) builder.getObject("main_stack");
        videosBox = cast(Box) builder.getObject("box_videos");
        infobar = cast(InfoBar) builder.getObject("infobar");
        header = cast(HeaderBar) builder.getObject("header");
        headerbtns = cast(ButtonBox) builder.getObject("header_btn_box");
        initMenus();

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

    void initMenus() {
        auto b = new Builder;
        b.addFromResource("/com/theweirddev/bingewatch/data/menus.ui");
        auto m = cast(MenuModel) b.getObject("import-menu");

        auto importTVAction = new SimpleAction("importTV", null);
        importTVAction.addOnActivate((v, a) => importTVShow());
        w.addAction(importTVAction);

        auto importMovieAction = new SimpleAction("importMovie", null);
        importMovieAction.addOnActivate((v, a) => importMovie());
        w.addAction(importMovieAction);

        auto mb = new MenuButton;
        auto icon = new Image;
        icon.setFromGicon(new ThemedIcon("list-add"), GtkIconSize.LARGE_TOOLBAR);
        mb.setImage(icon);
        mb.setMenuModel(m);
        headerbtns.add(mb);
        headerbtns.setChildNonHomogeneous(mb, true);

    }

    void showError(string text, bool autoClose = true) {
        showMessage(text, autoClose, true, GtkMessageType.ERROR);
    }

    void showMessage(string text, bool autoClose = true, bool showClose = true,
            GtkMessageType msgType = GtkMessageType.INFO) {
        message.setText(text);
        infobar.setMessageType(msgType);
        infobar.setRevealed(true);
        infobar.setShowCloseButton(showClose);
        if (infoTimeout !is null) {
            infoTimeout.stop();
        }
        if (autoClose)
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
                importMovie();
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
            s.add(new Shelf);
            contents.packStart(s, true, true, 0);
        }
        contents.showAll();
    }

    void importTVShow() {
        //TODO: Check if download is in progress
        auto name = "";
        auto dir = selectTVShowDir(name);

        if (dir.empty || name.empty) {
            return;
        }
        //TODO: Check if this show already exists
        auto tvs = lib.addTVShow(name, dir);
        showMessage("Downloading metadata. This takes a while, please wait.", false, false);

        loadMetadataFor(tvs, (TVShow tv, Exception e) {
            if (e !is null) {
                showError("Error: " ~ e.msg);
                return;
            }

            lib.update(tv);
            reloadLibary();
            showMessage("Done");
        });
    }

    void importMovie() {
        string name;
        auto file = selectMovieFile(name);
        if (file.empty || name.empty) {
            return;
        }
        //TODO: Check if this show already exists
        auto mv = lib.addMovie(name, file);
        showMessage("Downloading metadata. This takes a while, please wait.", false, false);

        loadMetadataFor(mv, (Movie m, Exception e) {
            if (e !is null) {
                showError("Error: " ~ e.msg);
                return;
            }

            lib.update(m);
            reloadLibary();
            showMessage("Done");
        });
    }

    string selectFileOrDir(string msg, FileChooserAction action) {
        if (action != FileChooserAction.SELECT_FOLDER && action != FileChooserAction.OPEN) {
            return "";
        }
        auto fcd = new FileChooserDialog(msg, w, action, ["Select", "Cancel"],
                [ResponseType.ACCEPT, ResponseType.CANCEL]);
        const res = fcd.run();
        auto ret = "";
        {
            scope (exit)
                fcd.destroy();
            if (res != ResponseType.ACCEPT) {
                return "";
            }
            ret = fcd.getFilename();
        }

        if ((!exists(ret)) || (action == FileChooserAction.SELECT_FOLDER && !isDir(ret))) {
            return "";
        } else if (FileChooserAction.OPEN && !isFile(ret)) {
            return "";
        }
        return ret;
    }

    string confirmName(string msg, string name) {
        auto d = new Dialog("Import", w, GtkDialogFlags.MODAL, [
                "Cancel", "Import"
                ], [ResponseType.CANCEL, ResponseType.ACCEPT]);
        d.setDefaultResponse(ResponseType.ACCEPT);

        auto box = new Box(GtkOrientation.VERTICAL, 5);
        box.setMargin(10);
        auto box2 = new Box(GtkOrientation.HORIZONTAL, 5);
        box2.setHexpand(true);

        auto lbl = new Label(msg);
        box2.add(lbl);

        auto ent = new Entry(name);
        ent.setHexpand(true);
        ent.addOnChanged((EditableIF) { name = ent.getText(); });
        box2.add(ent);

        box.add(box2);

        d.getContentArea().add(box);
        d.setDefaultSize(500, -1);
        d.showAll();
        auto res = d.run();
        scope (exit)
            d.destroy();
        if (res != ResponseType.ACCEPT) {
            return "";
        }
        return name;
    }

    string selectTVShowDir(out string name) {
        auto dir = selectFileOrDir("Select your TVShow directory", FileChooserAction.SELECT_FOLDER);
        if (dir.empty)
            return dir;
        name = dir[dir.lastIndexOf("/") + 1 .. $];
        name = confirmName("TVShow name:", name);
        if (name.empty)
            return name;
        return dir;
    }

    string selectMovieFile(out string name) {
        auto file = selectFileOrDir("Select your Movie", FileChooserAction.OPEN);
        if (file.empty)
            return file;
        name = file[file.lastIndexOf("/") + 1 .. file.lastIndexOf(".")];
        name = confirmName("Movie name:", name);
        if (name.empty)
            return name;
        return file;
    }

}
