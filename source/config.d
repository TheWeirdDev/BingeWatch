module config;

static {
    // REPLACE WITH YOUR OWN API KEY
    immutable API_KEY = "";
}

static immutable string[] supportedMimeTypes = [
    "video/3gpp", "video/dv", "video/fli", "video/flv", "video/mp4",
    "video/mp4v-es", "video/mpeg", "video/msvideo", "video/ogg",
    "video/quicktime", "video/vivo", "video/vnd.divx", "video/vnd.rn-realvideo",
    "video/vnd.vivo", "video/x-anim", "video/x-avi", "video/x-flc", "video/x-fli",
    "video/x-flic", "video/x-flv", "video/x-m4v", "video/x-matroska",
    "video/x-mpeg", "video/x-ms-asf", "video/x-msvideo", "video/x-ms-wm",
    "video/x-ms-wmv", "video/x-nsv", "video/x-ogm+ogg", "video/x-theora+ogg",
    "x-content/video-dvd", "x-content/video-vcd", "x-content/video-svcd"
];
