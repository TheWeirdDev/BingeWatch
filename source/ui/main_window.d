module ui.main_window;
import std.stdio;
import std.file;
import std.string, std.regex;
import std.concurrency, core.thread;
import core.time, core.memory;
import std.range;

import glib.Idle;

import vlc.vlc_player;
import ui.gtkall;
import ui.widgets.welcome;
import ui.widgets.shelf;
import ui.widgets.video_player;
import ui.widgets.movie_page;
import db.library;
import db.models;
import tmdb.tmdb;
import tmdb.metadata;
static import config;

private enum StackPage : string {
    MAIN_PAGE = "main_page",
    MOVIE_PAGE = "movie_page",
    SERIES_PAGE = "series_page",
    PLAYER_PAGE = "player_page",
    DISCOVER_PAGE = "discover_page"
}

class MainWindow {

private:
    Builder builder;
    VideoPlayer video_player;
    MoviePage moviePage;
    ApplicationWindow w;
    Stack mainStack;
    InfoBar infobar;
    HeaderBar header;
    ButtonBox headerbtns;
    Button back;
    Timeout infoTimeout;
    Label message;
    Box videosBox;
    Box contents;
    Library lib;
    StackPage[] pageStack;
    int width, height;

    void OpenTVShow(TVShow tv) {
        writeln("TVshow opened: ", tv.name);
    }

    void OpenMovie(Movie m) {
        writeln("Movie opened: ", m.file_path);

        w.getSize(width, height);
        moviePage.setMovie(m);
        changeView(StackPage.MOVIE_PAGE);
        // video_player.setMediaPath(m.file_path);
        // video_player.play();
    }

public:
    this() {
        lib = new Library;
        pageStack.reserve(4);
    }

    void show(ApplicationWindow win) {
        w = win;
        header = new HeaderBar();
        header.setShowCloseButton(true);
        header.setTitle("BingeWatch");
        w.setTitlebar(header);

        mainStack = new Stack();
        videosBox = new VBox(false, 0);
        infobar = new InfoBar();
        infobar.setMessageType(MessageType.INFO);
        videosBox.packStart(infobar, false, true, 0);

        headerbtns = new ButtonBox(GtkOrientation.HORIZONTAL);
        headerbtns.setSpacing(5);
        headerbtns.setHomogeneous(false);
        back = new Button();
        auto icon = new Image;
        icon.setFromGicon(new ThemedIcon("go-previous"), GtkIconSize.LARGE_TOOLBAR);
        back.setImage(icon);
        back.setSensitive(false);
        back.addOnClicked((Button) {
            switch (mainStack.getVisibleChildName()) {
            case StackPage.MAIN_PAGE:
                break;
            case StackPage.PLAYER_PAGE:
                if (video_player.isPlaying()) {
                    video_player.stop();
                }
                goto default;
            default:
                //w.setSizeRequest(width, height);
                //w.resize(width, height);
                mainStack.setVisibleChildName(StackPage.MAIN_PAGE);
            }
            pageStack.popFront();
            GC.collect();
        });
        headerbtns.packStart(back, true, true, 0);
        headerbtns.setChildNonHomogeneous(back, true);

        Button discover = new Button("Discover");
        discover.addOnClicked((Button) {});
        header.packEnd(discover);
        header.packStart(headerbtns);
        mainStack.addNamed(videosBox, StackPage.MAIN_PAGE);

        auto scr = w.getScreen();

        video_player = new VideoPlayer(scr.getWidth(), scr.getHeight());

        mainStack.addNamed(video_player, StackPage.PLAYER_PAGE);

        moviePage = new MoviePage((m) {
            changeView(StackPage.PLAYER_PAGE);
            video_player.setMediaPath(m.file_path);
            video_player.play();
        });

        mainStack.addNamed(moviePage, StackPage.MOVIE_PAGE);

        initMenus();
        message = new Label("");
        infobar.getContentArea().add(message); //infobar.addButton("Close", ResponseType.CLOSE);
        infobar.setRevealed(false);
        infobar.addOnResponse((int resp, InfoBar ifb) {
            if (cast(ResponseType) resp == ResponseType.CLOSE) {
                ifb.setRevealed(false);
            }
        });
        infobar.setShowCloseButton(true);

        mainStack.addOnNotify((ParamSpec, ObjectG) {
            back.setSensitive(mainStack.getVisibleChildName() != StackPage.MAIN_PAGE);
        }, "visible-child");
        contents = new Box(GtkOrientation.VERTICAL, 5);
        contents.setHexpand(true);
        contents.setVexpand(true);
        videosBox.add(contents);
        reloadLibary();

        w.setSizeRequest(750, 550);
        w.add(mainStack);
        w.showAll();

        video_player.modifyBg(GtkStateType.NORMAL, new Color(0, 0, 0)); // w.modifyBg(GtkStateType.NORMAL, new Color(0, 0, 0));
        //player.modifyBg(GtkStateType.NORMAL, new Color(0, 0, 0));
        //player.setEvents(GdkEventMask.EXPOSURE_MASK | GdkEventMask.LEAVE_NOTIFY_MASK | GdkEventMask.BUTTON_PRESS_MASK
        //  | GdkEventMask.POINTER_MOTION_MASK | GdkEventMask.POINTER_MOTION_HINT_MASK);
        // video_player.addOnEvent((Event, Widget w) {
        //     //x, y, w, h = widget.allocation
        //     GtkAllocation alloc;
        //     auto cr = createContext(w.getWindow());
        //     w.getAllocation(alloc);
        //     cr.rectangle(0, 0, alloc.width, alloc.height);
        //     cr.setSourceRgb(0, 0, 0);
        //     cr.fill();
        //     return true;
        // });

    }

    ~this() {

    }

private:

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
        headerbtns.packStart(mb, true, true, 0);
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
                w.destroy();
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
            s.add(new Shelf(&OpenTVShow, &OpenMovie));
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
        TVShow tvs = new TVShow;
        tvs.name = name;
        tvs.dir_path = dir;
        showMessage("Downloading metadata. This takes a while, please wait.", false, false);

        loadMetadataFor(tvs, (TVShow tv, Exception e) {
            if (e !is null) {
                showError("Error: " ~ e.msg);
                e.msg.writeln();
                return;
            }

            lib.update(tv);
            reloadLibary();
            showMessage("Done");
        });
    }

    void importMovie() {
        import std.algorithm : filter;

        string name;
        const file = selectMovieFile(name);
        if (file.empty || name.empty) {
            return;
        }
        //TODO: Check if this show already exists
        if (lib.getMovies().filter!(a => a.name == name || a.file_path == file)().array.length > 0) {
            showError("This movie is already added to the library", true);
            return;
        }
        showMessage("Downloading metadata. This takes a while, please wait.", false, false);

        loadMetadataForMovie(name, (Movie m, Exception e) {
            if (e !is null) {
                showError("Error: " ~ e.msg);
                return;
            }
            m.name = name;
            m.file_path = file;
            lib.add(m);
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
        if (action == FileChooserAction.OPEN) {
            FileFilter all = new FileFilter();
            all.setName("All files");
            all.addPattern("*");
            fcd.addFilter(all);

            FileFilter files = new FileFilter();
            files.setName("Supported video files");
            foreach (mime; config.supportedMimeTypes)
                files.addMimeType(mime);
            fcd.addFilter(files);
            fcd.setFilter(files);
        }
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

        auto re = ctRegex!(r"[._-]", "g");

        auto ent = new Entry(name.replaceAll(re, " "));
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

    auto changeView(StackPage page) {
        pageStack ~= page;
        mainStack.setVisibleChildName(page);
    }
}
