module ui.widgets.shelf;

import std.conv;

import utils.util;
import ui.gtkall;
import db.models;
import db.database;
import db.library;

private enum Width = 150, Height = 235;

class Shelf : FlowBox {
private:
    Database db;

public:
    this() {
        super();
        db = Database.getInstance();
        setHomogeneous(true);
        setSelectionMode(SelectionMode.NONE);
        setMaxChildrenPerLine(8);
        setMinChildrenPerLine(3);
        setColumnSpacing(5);
        setValign(GtkAlign.START);
        setRowSpacing(5);
        setMargin(this, 10);
        // for (int i = 0; i < 100; i++)
        foreach (ref tv; db.getShows()) {
            auto btn = new ShelfItemTVShow(tv);
            btn.setSizeRequest(Width, Height);
            add(btn);
        }
        foreach (ref m; db.getMovies()) {
            auto btn = new ShelfItemMovie(m);
            btn.setSizeRequest(Width, Height);
            add(btn);
        }
    }

}

private class BaseShelfItem(T) : FlowBoxChild {
private:
    Pixbuf pic = void;

protected:
    T data;

    this(ref T t) {
        super();
        data = t;

        auto box = new Box(GtkOrientation.VERTICAL, 5);
        auto btn = new Button();
        btn.setVexpand(true);
        btn.setHexpand(true);
        box.setHexpand(true);
        btn.setHalign(GtkAlign.CENTER);

        setSizeRequest(Width, Height);
        btn.setSizeRequest(Width, Height);

        box.addOnDraw((Scoped!Context c, Widget w) {

            if (!pic) {
                pic = new Pixbuf(getImagesDirName() ~ data.picture,
                    w.getAllocatedWidth(), w.getAllocatedHeight(), false);
            }

            c.setSourcePixbuf(pic, 0, 0);
            c.rectangle(0, 0, w.getAllocatedWidth(), w.getAllocatedHeight());
            c.fill();
            return false;
        });
        auto lblName = new Label(data.name);
        lblName.overrideBackgroundColor(GtkStateFlags.NORMAL, new RGBA(0, 0, 0, 0.4));
        lblName.setPadding(5, 5);
        lblName.modifyFg(GtkStateType.NORMAL, new Color(235, 235, 235));
        lblName.setLineWrap(true);
        lblName.setLineWrapMode(PangoWrapMode.WORD);
        lblName.setMaxWidthChars(10);
        box.packEnd(lblName, false, true, 0);

        auto starBox = new Box(GtkOrientation.HORIZONTAL, 3);
        starBox.overrideBackgroundColor(GtkStateFlags.NORMAL, new RGBA(0, 0, 0, 0.4));
        starBox.setHalign(GtkAlign.START);

        auto lblRateing = new Label(data.rating.to!string);
        lblRateing.setMarginRight(3);
        lblRateing.setPadding(0, 3);
        lblRateing.modifyFg(GtkStateType.NORMAL, new Color(235, 235, 235));

        auto starImg = new Image(new ThemedIcon("starred"), GtkIconSize.MENU);
        starImg.setMarginLeft(3);

        starBox.add(starImg);
        starBox.add(lblRateing);
        box.packStart(starBox, false, false, 0);

        btn.add(box);
        btn.setRelief(GtkReliefStyle.NONE);
        btn.addOnClicked(&clicked);
        add(btn);
    }

    T getData() {
        return data;
    }

    abstract void clicked(Button);
}

private class ShelfItemTVShow : BaseShelfItem!(TVShow) {

    this(ref TVShow tvs) {
        super(tvs);
    }

    override void clicked(Button b) {
        import std.stdio;

        writeln(getData().name);
    }
}

private class ShelfItemMovie : BaseShelfItem!(Movie) {
    this(ref Movie m) {
        super(m);
    }

    override void clicked(Button b) {
        import std.stdio;

        writeln(getData().name);
    }
}
