module ui.gtkall;

public {
    import gtk.Stack;
    import gtk.Label;
    import gtk.Button, gtk.ButtonBox, gtk.ToggleButton, gtk.MenuButton;
    import gtk.ApplicationWindow;
    import gtk.Main;
    import gdk.X11;
    import gtk.Builder;
    import gtk.Widget;
    import gtk.Box, gtk.VBox, gtk.HBox;
    import gdk.Event;
    import gtk.DrawingArea;
    import gtk.c.types;
    import gdk.Color;
    import gobject.Signals;
    import gdk.Event;
    import gdk.Cairo;
    import gtk.Grid;
    import gtk.CssProvider;
    import gtk.StyleContext;
    import gdk.Screen;
    import gtk.Image;
    import gtk.Container;
    import gtk.AspectFrame;
    import gtk.Overlay;
    import gtk.ProgressBar;

    // import gdk.Event;
    // import gobject.ParamSpec;
    // import gobject.ObjectG;
    import gtk.FileChooserDialog, gtk.FileFilter, gtk.Dialog;
    import gtk.Entry, gtk.EditableIF;
    import gtk.InfoBar;
    import gtk.HeaderBar;
    import gdk.Threads;
    import gio.ThemedIcon;
    import gtk.Requisition;
    import gtk.ScrolledWindow, gtk.FlowBox, gtk.FlowBoxChild;
    import gdk.Pixbuf, gdk.Color;
    import gdk.Window : GdkWin = Window;
    import gio.MenuModel, gio.Menu, gio.MenuItem;
    import gio.SimpleAction;
    import cairo.Context, gdk.RGBA;
    import glib.Timeout;
}

void setMargin(Widget t, int margin) {
    static foreach (side; ["Left", "Right", "Top", "Bottom"]) {
        mixin("t.setMargin" ~ side ~ "(margin);");
    }
}
