/*
 * This file contains Object definitions that are used
 * throughout the game
 * 
 */

/*
 * An object that represents a Ship
 */
function Ship (battleid, playerid, xpos, ypos, stype, orientation, afloat) {
	this.battleid = battleid;
	this.playerid = playerid;
	this.xpos = xpos;
	this.ypos = ypos;
	this.stype = stype;
	this.orientation = orientation;
	this.afloat = afloat;
}

/*
 * Draws the Ship on the given canvas
 */
Ship.prototype.draw = function (canvas) {
	var context = canvas.getContext("2d");
	var width = 0;
	var height = 0;
	var cellDimension = 35;
	var canvas_x;
	var canvas_y;
	
	switch (this.stype) {
		case 'carrier':
			if (this.orientation == 'vertical') {
				width = 15;
				height = 5 * cellDimension;
			}
			else {
				width = 5 * cellDimension;
				height = 15;
			}
			break;
		case 'battleship':
			if (this.orientation == 'vertical') {
				width = 15;
				height = 4 * cellDimension;
			}
			else {
				width = 4 * cellDimension;
				height = 15;
			}
			break;
		case 'submarine':
			if (this.orientation == 'vertical') {
				width = 15;
				height = 3 * cellDimension;
			}
			else {
				width = 3 * cellDimension;
				height = 15;
			}
			break;
		case 'cruiser':
			if (this.orientation == 'vertical') {
				width = 15;
				height = 3 * cellDimension;
			}
			else {
				width = 3 * cellDimension;
				height = 15;
			}
			break;
		case 'destroyer':
			if (this.orientation == 'vertical') {
				width = 15;
				height = 2 * cellDimension;
			}
			else {
				width = 2 * cellDimension;
				height = 15;
			}
			break;
	}
	
	canvas_x = (Columns[this.xpos].position + Columns[this.xpos + 1].position) / 2;
	canvas_y = (Rows[this.ypos].position + Rows[this.ypos + 1].position) / 2;
	
	canvas_x -= (this.orientation == 'vertical') ? width / 2 : cellDimension / 2;
	canvas_y -= (this.orientation == 'vertical') ? cellDimension / 2 : height / 2;
	
	context.beginPath();
    context.rect(canvas_x, canvas_y, width, height);
    context.fillStyle = '#8ED6FF';
    context.fill();
    context.lineWidth = 1;
    context.strokeStyle = 'none';
    context.stroke();
}

/*
 * Function to convert a Ships's position fields
 * from mouse coordinates into cell coordinates
 */
Ship.prototype.mouseToCell = function () {
	// convert xpos to column
	var i;
	for (i = 0; i < Columns.length - 1; i++) {
		if ((this.xpos > Columns[i].position) && (this.xpos < Columns[i+1].position)) {
			this.xpos = i;
			break;
		}
	}
	
	// convert ypos to row
	for (i = 0; i < Rows.length - 1; i++) {
		if ((this.ypos > Rows[i].position) && (this.ypos < Rows[i+1].position)) {
			this.ypos = i;
			break;
		}
	}
}

/*
 * Function to send a Shot to the server
 */
Ship.prototype.send = function () {
	$.ajax({
	  type: 'POST',
	  url: '/api/ship',
	  data: JSON.stringify(this),
	  success: receiveShip,
	  dataType: 'text'
	});
}

function receiveShip(response) {
	if (response == 'invalid') {
		alert('Invalid ship');
	}
	else {
		var ship_obj = eval('(' + response + ')');
		var the_ship = new Ship(ship_obj.battleid, ship_obj.playerid, ship_obj.xpos, ship_obj.ypos, ship_obj.stype, ship_obj.orientation, ship_obj.afloat);
		the_ship.draw(leftCanvas);
	}
}

/*
 * An object that represents a Line on a Canvas
 */
function Line (position) {
	this.position = position; 
}

/*
 * A object that represents a Shot, relies on the existence
 * of the Columns and Rows array to convert mouse coordinates
 * into cell coordinates.
 * 
 * battleid - unique string representing this battle
 * playerid - unique string representing this player
 * xpos - the xpos of the Shot
 * ypos - the ypos of the Shot
 * hit - true if a hit, false if miss
 */
function Shot (battleid, playerid, xpos, ypos, hit, id) {
	this.battleid = battleid;
	this.playerid = playerid;
	this.xpos = xpos;
	this.ypos = ypos;
	this.hit = hit;
	this.id = id;
}

/*
 * Function to convert a Shot's position fields
 * from mouse coordinates into cell coordinates
 */
Shot.prototype.mouseToCell = function () {
	// convert xpos to column
	var i;
	for (i = 0; i < Columns.length - 1; i++) {
		if ((this.xpos > Columns[i].position) && (this.xpos < Columns[i+1].position)) {
			this.xpos = i;
			break;
		}
	}
	
	// convert ypos to row
	for (i = 0; i < Rows.length - 1; i++) {
		if ((this.ypos > Rows[i].position) && (this.ypos < Rows[i+1].position)) {
			this.ypos = i;
			break;
		}
	}
}

/*
 * Function to draw a Shot on the given canvas
 */
Shot.prototype.draw = function (canvas) {
	var hitX;
	var hitY;
	var context = canvas.getContext("2d");
	
	hitX = (Columns[this.xpos].position + Columns[this.xpos + 1].position) / 2;
	hitY = (Rows[this.ypos].position + Rows[this.ypos + 1].position) / 2;
	
	if (this.hit == true) {
		context.fillStyle = 'red';
		context.beginPath();
		context.arc(hitX, hitY, 10, 0, 2 * Math.PI);
		context.closePath();
		context.fill();
		context.stroke();
	}
	else {
		context.fillStyle = 'blue';
		context.beginPath();
		context.arc(hitX, hitY, 10, 0, 2 * Math.PI);
		context.closePath();
		context.fill();
		context.stroke();
	}
}

/*
 * Function to send a Shot to the server
 */
Shot.prototype.send = function () {
	$.ajax({
	  type: 'POST',
	  url: '/api/shot',
	  data: JSON.stringify(this),
	  success: receiveShot,
	  dataType: 'text'
	});
}

function receiveShot(response) {
	if (response == 'invalid') {
		alert('Invalid shot');
	}
	else if (response == 'ships_missing') {
		alert('The other player has not placed all their ships yet');
	}
	else if (response == 'not your turn') {
		alert('It is not your turn');
	}
	else {
		var shot_obj = eval('(' + response + ')');
		var the_shot = new Shot(shot_obj.battleid, shot_obj.playerid, shot_obj.xpos, shot_obj.ypos, shot_obj.hit, shot_obj.id);
		the_shot.draw(rightCanvas);
		if (shot_obj.sunk == true) {
			alert ('Congratulations! You sunk their ship.');
		}
	}
}
