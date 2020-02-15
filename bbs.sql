CREATE TABLE posts (
    number INTEGER PRIMARY KEY,
    delete INTEGER,
    type   INTEGER,
    time   CHAR(24)
    userid VARCHAR(64),
    text   VARCHAR(1024),
    origin INTEGER
);
