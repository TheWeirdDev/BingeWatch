module ui.widgets.movie_page;

import ui.gtkall;
import db.models.movie;
import utils.util;

public class MoviePage : Overlay {
private:
    Movie currentMovie;
    ProgressBar watchedPB;
    Button playBtn;
    Label nameLbl;
    Label descLbl;
    Label yearLbl;
    Label durLbl;
    Label rateLbl;
    Label starLbl;

    void loadView() {
        auto coverBgBox = new HBox(false, 0);
        coverBgBox.addOnDraw((Scoped!Context c, Widget w) {
            auto bg = new Pixbuf(getImagesDirName() ~ currentMovie.cover_picture);
            bg = bg.scaleSimple(w.getAllocatedWidth(), w.getAllocatedHeight(),
                GdkInterpType.BILINEAR);
            bg.saturateAndPixelate(bg, 0.6, false);
            c.setSourcePixbuf(bg, 0, 0);
            c.rectangle(0, 0, w.getAllocatedWidth(), w.getAllocatedHeight());
            c.fill();
            return false;
        });
        coverBgBox.setOpacity(0.4);

        auto colorBgBox = new HBox(false, 0);
        colorBgBox.modifyBg(GtkStateType.NORMAL, new Color(0x55, 0x55, 0x55));
        addOverlay(colorBgBox);
        addOverlay(coverBgBox);

        auto vb = new VBox(false, 0);
        auto vb1 = new VBox(false, 0);
        auto hb1 = new HBox(false, 0);
        auto hb2 = new HBox(false, 0);
        starLbl = new Label("Star");
        rateLbl = new Label("Rate");
        hb2.packEnd(starLbl, false, true, 0);
        hb2.packEnd(rateLbl, false, true, 0);
        hb1.packEnd(hb2, false, true, 0);
        vb1.packStart(hb1, false, true, 0);
        vb.packStart(vb1, true, true, 0);

        auto hb3 = new HBox(false, 0);
        auto btnPlay = new Button(StockID.MEDIA_PLAY);
        nameLbl = new Label("Name");
        hb3.packStart(btnPlay, false, true, 0);
        hb3.packStart(nameLbl, true, true, 0);
        vb.packStart(hb3, false, true, 0);

        watchedPB = new ProgressBar;
        vb.packStart(watchedPB, false, true, 0);

        auto hb4 = new HBox(false, 0);
        yearLbl = new Label("Year: 2016");
        durLbl = new Label("Duration: 01:53");
        hb4.packStart(yearLbl, false, true, 0);
        hb4.packEnd(durLbl, false, true, 0);
        vb.packStart(hb4, false, true, 0);

        auto vb2 = new VBox(false, 0);
        auto lb5 = new Label("Desc:");
        descLbl = new Label("desc...");
        descLbl.setLineWrap(true);
        vb2.packStart(lb5, false, true, 0);
        vb2.packStart(descLbl, true, true, 0);
        vb.packStart(vb2, true, true, 0);
        addOverlay(vb);
    }

    void reloadView() {
        import std.conv : to;
        import std.datetime : dur;

        watchedPB.setFraction(currentMovie.watched / currentMovie.length);
        watchedPB.setFraction(0.75);
        nameLbl.setText(currentMovie.name);
        starLbl.setText(currentMovie.rating.to!string);
        rateLbl.setText(currentMovie.age_rating);
        descLbl.setText(currentMovie.description);
        yearLbl.setText(currentMovie.year.to!string);
        durLbl.setText(dur!"minutes"(currentMovie.length).to!string);
    }

public:
    this() {
        super();
        loadView();
    }

    ~this() {

    }

    auto setMovie(Movie m) {
        currentMovie = m;
        reloadView();
    }
}
