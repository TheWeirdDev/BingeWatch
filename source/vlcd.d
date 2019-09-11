module vlcd;

import vlc;

import std.string;
import std.conv;
import std.stdio;
import core.sys.posix.unistd;

class Vlc {

private:
    libvlc_instance_t* inst;
    libvlc_media_player_t* mp;
    libvlc_media_t* m;
    uint xid;

public:
    this(uint xid) {
        //libvlc_video_get_size
        this.xid = xid;
        immutable char*[] args = ["--no-xlib".toStringz];
        inst = libvlc_new(cast(int) args.length, args.ptr);
        const char* s = libvlc_get_version();
        writefln("vlc: %s", to!string(s));
        stdout.flush();
    }

    void setMediaPath(string s) {
        if (mp != null)
            libvlc_media_player_release(mp);
        m = libvlc_media_new_path(inst, toStringz(s));
        // while (libvlc_media_get_parsed_status(
        //         m) != libvlc_media_parsed_status_t.libvlc_media_parsed_status_done)
        //     usleep(15);
        mp = libvlc_media_player_new_from_media(m);
        libvlc_media_player_set_xwindow(mp, xid);
        libvlc_media_release(m);
    }

    void play() {
        libvlc_media_player_play(mp);
    }

    void stop() {
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
