module ui.widgets.video_player;

import std.string;
import std.stdio;
import std.conv;

import ui.gtkall;
import vlc.vlc;

class VideoPlayer : AspectFrame {
private:
    DrawingArea view;
    libvlc_instance_t* inst = null;
    libvlc_media_player_t* mp = null;
    libvlc_media_t* m = null;
    uint maxWidth, maxHeight;
    // extern (C) static void mediaParsedCallback(const(libvlc_event_t)* p_event, void* p_data) {
    //     if (cast(libvlc_media_parsed_status_t) p_event.u.media_parsed_changed.new_status
    //             == libvlc_media_parsed_status_t.libvlc_media_parsed_status_done) {
    //         VideoPlayer _this = cast(VideoPlayer) p_data;
    //         uint px, py;
    //         libvlc_video_get_size(_this.mp, 0, &px, &py);
    //         writeln(px, " , ", py);
    //         if (px > 0 && py > 0) {
    //             _this.view.setSizeRequest(px, py);
    //             _this.set(0.5, 0.5, cast(float) px / cast(float) py, false);
    //         } else {
    //             writeln("Couldn't determine video size");
    //         }
    //         libvlc_media_track_t** tracks;
    //         libvlc_media_tracks_get(_this.m, &tracks);
    //         writefln("%s", (**(tracks + 3)).i_type);
    //     } else {
    //         writeln("Failed to parse the video file");
    //     }
    // }

public:
    this(uint maxWidth, uint maxHeight) {
        super("", 0.5, 0.5, 16.0 / 9.0, false);
        this.maxWidth = maxWidth;
        this.maxHeight = maxHeight;

        immutable char*[] args = ["--no-xlib", "--gl=wgl"];
        inst = libvlc_new(cast(int) args.length, args.ptr);
        const char* s = libvlc_get_version();
        writefln("vlc: %s", to!string(s));
        stdout.flush();

        view = new DrawingArea;
        add(view);
        setShadowType(GtkShadowType.NONE);
        setLabelWidget(null);
    }

    void setMediaPath(string s) {
        m = libvlc_media_new_path(inst, toStringz(s));
        //libvlc_media_parse_with_options(m, libvlc_media_parse_flag_t.libvlc_media_fetch_local, 1000);
        //libvlc_event_attach(libvlc_media_event_manager(m), libvlc_event_e.libvlc_MediaParsedChanged,
        //        cast(libvlc_callback_t)&mediaParsedCallback, cast(void*) this);

        if (mp is null) {
            mp = libvlc_media_player_new_from_media(m);
            libvlc_media_player_set_xwindow(mp, view.getWindow().getXid());
        } else {
            libvlc_media_player_set_media(mp, m);
        }
        // libvlc_media_slave_t** slaves;
        // libvlc_media_slaves_get(m, &slaves);
        //writefln("Slaves: %X", slaves);
        libvlc_media_release(m);
    }

    void play() {
        libvlc_media_player_play(mp);
        libvlc_media_parse(m);
        if (libvlc_media_get_parsed_status(
                m) == libvlc_media_parsed_status_t.libvlc_media_parsed_status_done) {
            uint px, py;
            libvlc_video_get_size(mp, 0, &px, &py);
            writeln(px, " , ", py);
            if (px > 0 && py > 0) {
                // view.setSizeRequest((px < maxWidth) ? px : maxWidth - 1,
                //         (py < maxHeight) ? py : maxHeight - 1);
                set(0.5, 0.5, cast(float) px / cast(float) py, false);
            } else {
                writeln("Couldn't determine video size");
            }
            libvlc_media_track_t** tracks;
            const track_size = libvlc_media_tracks_get(m, &tracks);
            auto t = tracks;
            scope (exit)
                libvlc_media_tracks_release(t, track_size);
            foreach (i; 0 .. track_size) {
                writefln("%s", to!string((**tracks).psz_language));
                tracks++;
            }
        }
    }

    void stop() {
        view.setSizeRequest(-1, -1);
        libvlc_media_player_stop(mp);
    }

    bool isPlaying() {
        return libvlc_media_player_is_playing(mp) != 0;
    }

    void setSubtitle(string file) {
        libvlc_media_player_add_slave(mp, libvlc_media_slave_type_t.libvlc_media_slave_type_subtitle,
                cast(char*) toStringz(file), true);
    }

    ~this() {
        libvlc_media_player_release(mp);
        libvlc_release(inst);
    }
}
