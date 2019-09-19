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
        lblName.setPadding(5, 5);
        lblName.modifyFg(GtkStateType.NORMAL, new Color(235, 235, 235));
        lblName.setLineWrap(true);
        lblName.setLineWrapMode(PangoWrapMode.CHAR);
        lblName.setMaxWidthChars(10);
        box.packEnd(lblName, false, true, 0);

        auto starBox = new Box(GtkOrientation.HORIZONTAL, 3);
        starBox.overrideBackgroundColor(GtkStateFlags.NORMAL, new RGBA(0, 0, 0, 0.4));
        starBox.setHalign(GtkAlign.START);

        auto lblRateing = new Label(tvs.rating.to!string);
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
        btn.addOnClicked(&activate);
        add(btn);
    }

private:
    void activate(Button b) {
        import std.stdio;

        writeln(getData().name);
    }
}
