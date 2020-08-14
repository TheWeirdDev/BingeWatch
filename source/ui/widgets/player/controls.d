module ui.widgets.player.controls;

import ui.gtkall;

public class PlayerControls : VBox {
private:
    HBox timeBox;
    HBox controlsBox;
    Button playBtn;
    Scale timeSlider;
public:
    this() {
        super(false, 0);
        timeBox = new HBox(false, 0);
        controlsBox = new HBox(false, 0);

        timeSlider = new Scale(GtkOrientation.HORIZONTAL, 0.0, 100.0, 0.5);
        timeSlider.setDrawValue(false);
        // timeSlider.addOnFormatValue((double d, Scale s) {
        //     import utils.util;

        //     return durationToString(cast(long) d * 1000);
        // });

        timeBox.add(timeSlider);

        playBtn = new Button("Play");
        controlsBox.add(playBtn);

        packStart(timeBox, true, true, 0);
        packStart(controlsBox, true, true, 0);
    }

    void addOnPlayPause(void delegate(Button) deleg) {
        playBtn.addOnClicked(deleg);
    }

    void addOnTimeChanged(void delegate(Range) deleg) {
        timeSlider.addOnValueChanged(deleg);
    }

    void setMaxDuration(long d) {
        timeSlider.setAdjustment(new Adjustment(0, 0, d, 1, 10, 10));
    }

}
