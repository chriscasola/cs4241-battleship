
CREATE TABLE users (
	userid integer PRIMARY KEY,
	name varchar NOT NULL UNIQUE,
	email varchar,
	password varchar NOT NULL,
	icon integer DEFAULT 0,
	wins integer DEFAULT 0
);

CREATE TABLE online_users (
	sessionid varchar PRIMARY KEY,
	userid integer REFERENCES users(userid),
	timein timestamp DEFAULT CURRENT_TIMESTAMP,
	laston timestamp DEFAULT CURRENT_TIMESTAMP,
	available boolean DEFAULT false
);

CREATE TYPE battlestatus AS ENUM ('p1turn', 'p2turn', 'p1win', 'p2win', 'tie', 'endofworld');

CREATE TABLE battles (
	battleid integer PRIMARY KEY,
	p1id integer NOT NULL REFERENCES users(userid),
	p2id integer NOT NULL REFERENCES users(userid),
	size integer DEFAULT 2 CHECK (size>0 AND size<4),
	startdate timestamp DEFAULT CURRENT_TIMESTAMP,
	enddate timestamp,
	status battlestatus DEFAULT 'p1turn'
);

CREATE TYPE shiptype AS ENUM ('carrier', 'battleship', 'submarine', 'cruiser', 'destroyer');

CREATE TABLE ships (
	battleid integer REFERENCES battles(battleid) ON DELETE CASCADE,
	playerid integer REFERENCES users(userid),
	xpos integer,
	ypos integer,
	type shiptype NOT NULL,
	orientation boolean NOT NULL, /* true=horizontal, false=vertical */
	afloat boolean DEFAULT true,
	CONSTRAINT pk_ships PRIMARY KEY (battleid, playerid, xpos, ypos)
);

CREATE TABLE moves (
	battleid integer REFERENCES battles(battleid) ON DELETE CASCADE,
	playerid integer REFERENCES users(userid),
	xpos integer,
	ypos integer,
	hit boolean NOT NULL,
	time timestamp DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT pk_moves PRIMARY KEY (battleid, playerid, xpos, ypos)
);
