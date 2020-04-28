module ui.widgets.movie_page;

import ui.gtkall;
import db.models.movie;
import utils.util;

public class MoviePage : Overlay {
private:
    Movie currentMovie;
    ProgressBar watchedPB;
    Button playBtn;
    Label descLbl;

    auto loadView() {
        auto coverBgBox = new HBox(false, 0);
        coverBgBox.addOnDraw((Scoped!Context c, Widget w) {
            auto bg = new Pixbuf(getImagesDirName() ~ currentMovie.cover_picture);
            bg = bg.scaleSimple(w.getAllocatedWidth(), w.getAllocatedHeight(),
                GdkInterpType.BILINEAR);
            bg.saturateAndPixelate(bg, 0.4, false);
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

        watchedPB = new ProgressBar;
        auto vb = new VBox(false, 0);
        vb.packStart(watchedPB, false, true, 0);
        addOverlay(vb);
    }

    auto reloadView() {
        watchedPB.setFraction(currentMovie.watched / currentMovie.length);
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
