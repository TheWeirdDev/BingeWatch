module ui.widgets.shelf;

import std.conv;

import utils.util;
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
            auto btn = new ShelfItemTVShow(tv);
            btn.setSizeRequest(Width, Height);
            add(btn);
        }
    }

    void reload() {
        removeAll();

    }
}

private class BaseShelfItem(T) : FlowBoxChild {
protected:
    T data;

    this(T t) {
        super();
        data = t;
    }

    T getData() {
        return data;
    }
}

private class ShelfItemTVShow : BaseShelfItem!(TVShow) {

public:
    this(TVShow tvs) {
        super(tvs);

        auto box = new Box(GtkOrientation.VERTICAL, 5);
        auto btn = new Button();
        btn.setVexpand(true);
        btn.setHexpand(true);
        box.setHexpand(true);
        btn.setHalign(GtkAlign.CENTER);

        setSizeRequest(Width, Height);
        btn.setSizeRequest(Width, Height);

        box.addOnDraw((Scoped!Context c, Widget w) {
            Pixbuf p = new Pixbuf(getImagesDirName() ~ tvs.picture,
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
        btn.setRelief(GtkReliefStyle.NORMAL);
        add(btn);
    }

}
