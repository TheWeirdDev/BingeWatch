module db.database;

import hibernated.core;
import std.algorithm;
import db.models;
import utils.util;
import ddbc.drivers.sqliteddbc;

// static import std.file;

private enum dbName = "db.sqlite";

public class Database {
private:
    SessionFactory sFactory;
    Session sess;

    static bool instantiated_;
    __gshared Database instance_;

public:
    static Database getInstance() {
        if (!instantiated_) {
            synchronized (Database.classinfo) {
                if (!instance_) {
                    instance_ = new Database();
                }
                instantiated_ = true;
            }
        }
        return instance_;
    }

    this() {
        auto dbFile = getConfigDirName() ~ dbName;
        EntityMetaData schema = new SchemaInfoImpl!(TVShow, Episode, Movie);
        SQLITEDriver driver = new SQLITEDriver();
        // if (std.file.exists(dbFile))
        //     std.file.remove(dbFile);
        string[string] params;
        Dialect dialect = new SQLiteDialect();
        DataSource ds = new ConnectionPoolDataSourceImpl(driver, dbFile, params);
        sFactory = new SessionFactoryImpl(schema, dialect, ds);
        {
            Connection conn = ds.getConnection();
            scope (exit)
                conn.close();
            // create tables if not exist
            sFactory.getDBMetaData().updateDBSchema(conn, false, true);
        }
        sess = sFactory.openSession();
    }

    ~this() {
        close();
    }

    void close() {
        sess.close();
        sFactory.close();
    }

    void refresh(ref TVShow tvs) {
        sess.refresh(tvs);
    }

    void refresh(ref Movie m) {
        sess.refresh(m);
    }

    Movie[] getMovies(string order = "name") {
        auto res = sess.createQuery("FROM Movie ORDER BY " ~ order).list!Movie();
        foreach (ref m; res) {
            refresh(m);
        }
        return res;
    }

    TVShow[] getShows(string order = "name") {
        auto res = sess.createQuery("FROM TVShow ORDER BY " ~ order).list!TVShow();
        foreach (ref tv; res) {
            refresh(tv);
        }
        return res;
    }

    TVShow getShow(string name) {
        return sess.createQuery("FROM TVShow WHERE name=:Name")
            .setParameter("Name", name).uniqueResult!TVShow();
    }

    TVShow getShow(long id) {
        return sess.createQuery("FROM TVShow WHERE id=:Id").setParameter("Id",
                id).uniqueResult!TVShow();
    }

    void updateItem(Object o) {
        synchronized (Database.classinfo) {
            sess.update(o);
        }
    }

    void addItem(Object o) {
        synchronized (Database.classinfo) {
            sess.save(o);
        }
    }

    void removeItem(Object o) {
        synchronized (Database.classinfo) {
            sess.remove(o);
        }
    }

}
