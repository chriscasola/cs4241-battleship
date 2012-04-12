
/**
 * Keeps track of information important for login and management of a user 
 * account.
 *
 * Columns:
 *   userid		This is an automatically generated id for the user.
 *   name		The name of the user.
 *   email		The email which is used to log in and for password resets.
 *   password	The hashed password of the user. NOTE: We should implement a 
 *				salting system as well.
 */
CREATE TABLE users (
	userid SERIAL PRIMARY KEY,
	name varchar NOT NULL UNIQUE,
	email varchar NOT NULL UNIQUE,
	password varchar NOT NULL
);

/**
 * Keeps track of users who are currently logged in.
 *
 * Columns:
 *   sessionid	The session id of the logged on user.
 *   userid		The id of a specific logged on user.
 *   timein		When the user logged on. This column's value is set when the 
 				user logs in.
 *   laston		When the user last accessed the website while logged in. This 
 *				field must be updated every time the user performs an action.
 */
CREATE TABLE users_online (
	sessionid varchar PRIMARY KEY,
	userid integer REFERENCES users(userid),
	timein timestamp DEFAULT CURRENT_TIMESTAMP,
	laston timestamp DEFAULT CURRENT_TIMESTAMP
);

/**
 * The users_icons table keeps track of what icon each user has. An entry for 
 * a user does not have to be created when the user is created. If there is no 
 * row for a specific userid, then the user has no icon.
 */
CREATE TABLE users_icons (
	userid integer PRIMARY KEY REFERENCES users(userid),
	icon integer DEFAULT 0
);

/**
 * Keeps track of users who are waiting for a battle opponent.
 */
CREATE TABLE users_waiting (
	userid integer PRIMARY KEY REFERENCES users(userid),
	startedWaiting timestamp DEFAULT CURRENT_TIMESTAMP
);

/**
 * An enum for identifying the status of a battle.
 */
CREATE TYPE battlestatus AS ENUM ('p1turn', 'p2turn', 'p1win', 'p2win', 'tie', 'endofworld');

/**
 * Keeps track of individual battles.
 *
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

/**
 * An enum for identifying a type of ship.
 */
CREATE TYPE shiptype AS ENUM ('carrier', 'battleship', 'submarine', 'cruiser', 'destroyer');

/**
 * An enum for identifying whether or a ship is placed horizontally or 
 * vertically.
 */
CREATE TYPE orientation AS ENUM ('horizontal', 'vertical');

/**
 * Keeps track of a user's ship positions on the field of a particular battle.
 *
 * Columns:
 *   battleid		The id of the battle in which the ship is taking part.
 *   playerid		The id of the player who owns the ship.
 *   xpos			The x location of the leftmost peg of the ship.
 *   ypos			The y location of the uppermost peg of the ship.
 *   stype			They type of ship that is being placed.
 *   orientation	Whether or not the ship is horizontal or vertical.
 *   afloat			Whether or not the ship is afloat.
 */
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

/**
 * Keeps track of a user's moves in a particular battle.
 */
CREATE TABLE battle_moves (
	battleid integer REFERENCES battles(battleid) ON DELETE CASCADE,
	playerid integer REFERENCES users(userid),
	xpos integer,
	ypos integer,
	hit boolean NOT NULL,
	time timestamp DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT pk_moves PRIMARY KEY (battleid, playerid, xpos, ypos)
);
