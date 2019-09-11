module ui.widgets.shelf;

import std.conv;

import ui.gtkall;
import db.models;
import db.library;

private enum Width = 150, Height = 235;

class Shelf : FlowBox {
private:
    Library lib;

public:
    this(Library l) {
        super();
        lib = l;
        setHomogeneous(true);
        setSelectionMode(SelectionMode.NONE);
        setMaxChildrenPerLine(8);
        setMinChildrenPerLine(3);
        setColumnSpacing(5);
        setValign(GtkAlign.START);
        setRowSpacing(5);
        setMargin(this, 10);
        // for (int i = 0; i < 100; i++)
        foreach (ref tv; lib.getShows()) {
            //auto ch = new FlowBoxChild();
            auto btn = new ShelfItem(tv);
            btn.setSizeRequest(Width, Height);
            add(btn);
            //add(ch);
        }
    }

    void reload() {
        removeAll();

    }
}

private class ShelfItem : FlowBoxChild {
private:
    union {
        TVShow show;
        Movie movie;
    }

    enum Tag {
        TVSHOW,
        MOVIE
    }

    Tag tag;

public:
    this(TVShow tvs) {
        auto box = new Box(GtkOrientation.VERTICAL, 5);
        auto btn = new Button();
        btn.setVexpand(true);
        btn.setHexpand(true);
        // btn.setRelief(GtkReliefStyle.HALF);
        setSizeRequest(Width, Height);

        box.addOnDraw((Scoped!Context c, Widget w) {
            Pixbuf p = new Pixbuf("/home/alireza/Downloads/desSj4kx0y9p61vm9QBE3Wm8GxK.jpg",
                w.getAllocatedWidth(), w.getAllocatedHeight(), false);
            c.setSourcePixbuf(p, 0, 0);
            c.rectangle(0, 0, w.getAllocatedWidth(), w.getAllocatedHeight());
            c.fill();
            return false;
        });
        auto lblName = new Label(tvs.name);
        lblName.overrideBackgroundColor(GtkStateFlags.NORMAL, new RGBA(0, 0, 0, 0.4));
        lblName.setPadding(7, 7);
        lblName.setLineWrap(true);
        lblName.setLineWrapMode(PangoWrapMode.CHAR);
        lblName.setMaxWidthChars(10);
        box.packEnd(lblName, false, true, 0);
        //box.add(new Label(tvs.year.to!string));
        btn.add(box);
        add(btn);
        show = tvs;
        tag = Tag.TVSHOW;
    }

    this(Movie m) {

    }
}
