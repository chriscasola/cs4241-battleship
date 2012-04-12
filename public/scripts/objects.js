/*
 * This file contains Object definitions that are used
 * throughout the game
 * 
 */

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
	
	if ((this.xpos == undefined) || (this.ypos == undefined) || (Columns[this.xpos] == undefined) || (Columns[this.xpos + 1] == undefined) || (Rows[this.ypos] == undefined) || (Rows[this.ypos + 1] == undefined)) {
		alert ('undefined for ' + this.id);
	}
	
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
	else {
		var shot_obj = eval('(' + response + ')');
		var the_shot = new Shot(shot_obj.battleid, shot_obj.playerid, shot_obj.xpos, shot_obj.ypos, shot_obj.hit, shot_obj.id);
		the_shot.draw(document.getElementById('myBoard'));
	}
}
