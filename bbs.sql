CREATE TABLE accounts (
    userid   VARCHAR(64) PRIMARY KEY,
    salt     CHAR(32),
    hashed   CHAR(32),
    username VARCHAR(64)
);

CREATE TABLE posts (
    number INTEGER PRIMARY KEY,
    exist  INTEGER,
    type   INTEGER,
    time   CHAR(24),
    userid VARCHAR(64),
    text   VARCHAR(1024),
    origin INTEGER
);
