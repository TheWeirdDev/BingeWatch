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
    Pixbuf bg;
    VBox vb, vb1, vb2;
    HBox hb1, hb2, hb3, hb4, hbx;

    void loadView() {
        vb = new VBox(false, 0);
        vb.getStyleContext().addClass("movie_info");

        vb1 = new VBox(false, 0);
        hb1 = new HBox(false, 0);
        hb2 = new HBox(false, 0);
        hbx = new HBox(false, 0);

        vb.addOnDraw((Scoped!Context c, Widget w) {
            auto bg2 = bg.copy().scaleSimple(w.getAllocatedWidth(),
                w.getAllocatedHeight(), GdkInterpType.BILINEAR);
            c.setSourcePixbuf(bg2, 0, 0);
            const width = w.getAllocatedWidth();
            const height = w.getAllocatedHeight();
            c.rectangle(0, 0, width, height);
            c.fill();
            c.setSourceRgba(0, 0, 0, 0.6);
            c.rectangle(0, 0, width, height);
            c.fill();
            return false;
        });

        starLbl = new Label("Star");
        rateLbl = new Label("Rate");
        hb2.packEnd(starLbl, false, true, 0);
        hb2.packEnd(rateLbl, false, true, 0);
        hb1.packEnd(hb2, false, true, 0);
        vb1.packStart(hb1, false, true, 0);
        vb1.packStart(hbx, true, true, 0);
        vb.packStart(vb1, true, true, 0);

        hb3 = new HBox(false, 10);
        hb3.setMargin(10);
        playBtn = new Button("Play");
        playBtn.setImage(new Image("media-playback-start", GtkIconSize.LARGE_TOOLBAR));
        playBtn.setAlwaysShowImage(true);
        playBtn.getStyleContext().addClass("play-btn");
        // playBtn.setSizeRequest(200, 200);

        nameLbl = new Label("Name");
        nameLbl.getStyleContext().addClass("movie_name");
        nameLbl.setJustify(GtkJustification.LEFT);
        nameLbl.setXalign(0);
        hb3.packStart(playBtn, false, false, 0);
        hb3.packStart(nameLbl, true, true, 0);
        vb.packStart(hb3, false, true, 0);

        watchedPB = new ProgressBar;
        watchedPB.setMarginStart(10);
        watchedPB.setMarginEnd(10);
        vb.packStart(watchedPB, false, true, 0);

        hb4 = new HBox(false, 0);
        yearLbl = new Label("Year: xxxx");
        durLbl = new Label("Duration: xx:xx");
        hb4.packStart(yearLbl, false, true, 0);
        hb4.packEnd(durLbl, false, true, 0);
        hb4.setMargin(10);
        vb.packStart(hb4, false, true, 0);

        vb2 = new VBox(false, 0);
        // vb2.addOnDraw((Scoped!Context c, Widget w) {
        //     const width = w.getAllocatedWidth();
        //     const height = w.getAllocatedHeight();
        //     c.setSourceRgba(0, 0, 0, 0.3);
        //     c.rectangle(0, 0, width, height);
        //     c.fill();
        //     return false;
        // });
        auto lb5 = new Label("Desc:");
        descLbl = new Label("desc...");
        descLbl.setMargin(15);
        descLbl.setJustify(GtkJustification.FILL);
        descLbl.setLineWrap(true);
        vb2.packStart(lb5, false, true, 0);
        vb2.packStart(descLbl, false, true, 0);
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
        yearLbl.setText("Year: " ~ currentMovie.year.to!string);
        durLbl.setText(currentMovie.length
                .dur!"minutes"
                .to!string);
    }

public:
    this() {
        super();
        loadView();
    }

    ~this() {

    }

    auto setMovie(Movie m) {
        import ui.pixbuf_blur : pixbuf_blur;

        currentMovie = m;
        bg = new Pixbuf(getImagesDirName() ~ currentMovie.cover_picture);
        bg = pixbuf_blur(bg, 5);
        // bg.saturateAndPixelate(bg, 0.7, false);
        reloadView();
    }
}
