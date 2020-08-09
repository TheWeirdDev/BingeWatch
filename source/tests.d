module source.tests;

import std.stdio;

/* SQL unittests */
unittest {
    // import hibernated.core;
    // import std.algorithm, std.conv;
    // import db.models;

    // writeln("Running sql unittests:");

    // EntityMetaData schema = new SchemaInfoImpl!(TVShow, Episode, Movie);

    // import ddbc.drivers.sqliteddbc;

    // SQLITEDriver driver = new SQLITEDriver();
    // string url = "zzz.db";
    // static import std.file;

    // if (std.file.exists(url))
    //     std.file.remove(url);
    // string[string] params;
    // Dialect dialect = new SQLiteDialect();

    // DataSource ds = new ConnectionPoolDataSourceImpl(driver, url, params);

    // SessionFactory factory = new SessionFactoryImpl(schema, dialect, ds);
    // scope (exit)
    //     factory.close();

    // {
    //     Connection conn = ds.getConnection();
    //     scope (exit)
    //         conn.close();
    //     // create tables if not exist
    //     factory.getDBMetaData().updateDBSchema(conn, false, true);
    // }

    // // Now you can use HibernateD

    // // create session
    // Session sess = factory.openSession();
    // scope (exit)
    //     sess.close();

    // use session to access DB

    // read all users using query
    // Query q = sess.createQuery("FROM User ORDER BY name");
    // User[] list = q.list!User();

    // create sample data
    // TVShow seinfeld = new TVShow;
    // seinfeld.name = "Seinfeld";
    // seinfeld.description = "A comedy show";
    // seinfeld.quality = "720p";
    // seinfeld.dir_path = "/a/b";
    // seinfeld.year = 1990;
    // seinfeld.rating = 9.9;
    // seinfeld.creators = ["a", "b"].to!string;
    // seinfeld.genres = to!string(["Comedy", "Sitcom"]);

    // Episode s01e01 = new Episode;
    // s01e01.name = "Pilot";
    // s01e01.num = 1;
    // s01e01.season = 1;
    // s01e01.tvshow = seinfeld;

    // //seinfeld.episodes ~= s01e01;

    // Episode s01e02 = new Episode;
    // s01e02.name = "Second Episode";
    // s01e02.num = 2;
    // s01e02.season = 1;
    // s01e02.tvshow = seinfeld;

    // sess.save(seinfeld);
    // writeln(seinfeld.id);
    // sess.save(s01e01);
    // sess.save(s01e02);

    // // load and check data
    // TVShow u11 = sess.createQuery("FROM TVShow WHERE name=:Name")
    //     .setParameter("Name", "Seinfeld").uniqueResult!TVShow();
    // foreach (e; u11.episodes) {
    //     writefln("Name: %s, Num: %d, Show: %s", e.name, e.num, e.tvshow.name);
    // }
    // Episode[] eps = sess.createQuery("FROM Episode ORDER BY num").list!Episode();
    // foreach (e; eps) {
    //     writefln("Name: %s, Num: %d, Show: %s", e.name, e.num, e.tvshow.name);
    // }
    // assert(u11.genres == "[\"Comedy\", \"Sitcom\"]");
    // assert(to!(string[])(u11.genres) == ["Comedy", "Sitcom"]);
    //remove reference
    // foreach(ep; u11.episodes){
    // 	sess.remove(ep);
    // }
    // sess.update(u11);

    // // remove entity
    // sess.remove(u11);
    writeln("============================");
}

/* test tmdb api */
