# 📺 BingeWatch
BingeWatch is a Linux Gtk app that helps you organize and watch your movies and tv shows.

![bingewatch_screenshot](screenshot.png)
# :hammer_and_wrench: Build
You need `ldc` and `dub` installed on your system.

First get your themoviedb.org API_KEY from [here](https://www.themoviedb.org/settings/api)

Then Add it to [source/config.d:7](source/config.d#L7):

```D
static {
    // REPLACE WITH YOUR OWN API KEY
    immutable API_KEY = "";
}
```

And then compile and run the program:

```bash
cd BingeWatch
dub --compiler=ldc
```

# License
BingeWatch is a free software and is licensed under GNU Public License v3+

For more information see [LICENSE](LICENSE)