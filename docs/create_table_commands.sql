
/**
 * The users table keeps track of information important for login and 
 * management of a user account.
 */
CREATE TABLE users (
	userid integer PRIMARY KEY,
	name varchar NOT NULL UNIQUE,
	email varchar,
	password varchar NOT NULL,
);

/**
 * The users_online table is for keeping track of users who are currently 
 * logged in.
 */
CREATE TABLE users_online (
	sessionid varchar PRIMARY KEY,
	userid integer REFERENCES users(userid),
	timein timestamp DEFAULT CURRENT_TIMESTAMP,
	laston timestamp DEFAULT CURRENT_TIMESTAMP
);

/**
 * The users_icons table keeps track of what icon each user has.
 */
CREATE TABLE users_icons (
	userid integer PRIMARY KEY REFERENCES users(userid),
	icon integer DEFAULT 0
);

/**
 * The users_waiting_for_battle table keeps track of users who are waiting for 
 * a battle opponent.
 */
CREATE TABLE users_waiting_for_battle (
	userid integer REFERENCES users(userid),
	startedWaiting timestamp DEFAULT CURRENT_TIMESTAMP
);

CREATE TYPE battlestatus AS ENUM ('p1turn', 'p2turn', 'p1win', 'p2win', 'tie', 'endofworld');

/**
 * Use a special SELECT statement to find the number of wins and losses a user has.
 */
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

CREATE TYPE orientation AS ENUM ('horizontal', 'vertical');

CREATE TABLE battle_positions (
	battleid integer REFERENCES battles(battleid) ON DELETE CASCADE,
	playerid integer REFERENCES users(userid),
	xpos integer,
	ypos integer,
	stype shiptype NOT NULL,
	orientation orientation NOT NULL,
	afloat boolean DEFAULT true,
	CONSTRAINT pk_ships PRIMARY KEY (battleid, playerid, xpos, ypos)
);

CREATE TABLE battle_moves (
	battleid integer REFERENCES battles(battleid) ON DELETE CASCADE,
	playerid integer REFERENCES users(userid),
	xpos integer,
	ypos integer,
	hit boolean NOT NULL,
	time timestamp DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT pk_moves PRIMARY KEY (battleid, playerid, xpos, ypos)
);
