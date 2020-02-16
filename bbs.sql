CREATE TABLE accounts (
    userid VARCHAR(32) PRIMARY KEY,
    salt   CHAR(32),
    hashed CHAR(32),
    name   VARCHAR(64)
);

CREATE TABLE posts (
    number INTEGER PRIMARY KEY,
    exist  INTEGER,
    kind   INTEGER,
    time   CHAR(24),
    userid VARCHAR(64),
    text   VARCHAR(1024),
    origin INTEGER
);
