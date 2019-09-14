module ui.gtkall;

public {
    import gtk.Stack;
    import gtk.Label;
    import gtk.Button;
    import gtk.Window;
    import gtk.Main;
    import gdk.X11;
    import gtk.Builder;
    import gtk.Widget;
    import gtk.Box;
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

    // import gdk.Event;
    // import gobject.ParamSpec;
    // import gobject.ObjectG;
    import gtk.FileChooserDialog, gtk.Dialog;
    import gtk.Entry, gtk.EditableIF;
    import gtk.InfoBar;
    import gdk.Threads;
    import gtk.ScrolledWindow, gtk.FlowBox, gtk.FlowBoxChild;
    import gdk.Pixbuf, gdk.Color;
    import gdk.Window : GdkWin = Window;

    import cairo.Context, gdk.RGBA;
    import glib.Timeout;
}

void setMargin(Widget t, int margin) {
    t.setMarginLeft(margin);
    t.setMarginRight(margin);
    t.setMarginTop(margin);
    t.setMarginBottom(margin);
}
