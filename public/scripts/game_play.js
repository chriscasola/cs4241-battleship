/*
 * This file provides the functions that deal with
 * the user's interaction with the game boards
 */

var last_shot_received = 0;
var my_turn = null;

function placeShip(event) {
	var clickPos = getClickPosition(event, event.target);
	var shipType = getShipType();
	var orientation = getShipOrientation();
	var the_ship = new Ship(sessionStorage['battleid'], sessionStorage['playerid'], clickPos.x, clickPos.y, shipType, orientation, true);
	the_ship.mouseToCell();
	the_ship.send();
}

function getShipType() {
	var ship_options = document.getElementById('shipSelection').children;
	var i;
	for( i = 0; i < ship_options.length; i++) {
		if(ship_options[i].children[0].checked) {
			return ship_options[i].childNodes[0].getAttribute('id');
		}
	}
}

function getShipOrientation() {
	var orient_options = document.getElementById('orientationSelection').children;
	var i;
	for( i = 0; i < orient_options.length; i++) {
		if(orient_options[i].children[0].checked) {
			return orient_options[i].childNodes[0].getAttribute('id');
		}
	}
}

function canvasClick(event) {
	// get location where the user clicked
	var clickPos = getClickPosition(event, event.target);

	// construct a Shot representing this click
	var thisShot = new Shot(sessionStorage['battleid'], sessionStorage['playerid'], clickPos.x, clickPos.y, false, 0);
	thisShot.mouseToCell();

	// send the shot to the server and draw the shot upon response
	thisShot.send();
}

/*
 * Retrieve all of the users's ships that are in the current battle
 */
function getShips() {
	$.ajax({
		type : 'GET',
		url : '/api/ship?request=' + JSON.stringify({battleid : sessionStorage['battleid'], playerid : sessionStorage['playerid']}),
		success : receiveShips,
		dataType : 'text'
	});
}

/*
 * Display each of the retrieved ships on the game board
 */
function receiveShips(response) {
	response = eval('(' + response + ')');
	if (response.success == "false") {
		alert(response.message);
	}
	else {
		ship_list = response.message;
		var i;
		for( i = 0; i < ship_list.length; i++) {
			var ship_obj = ship_list[i];
			var the_ship = new Ship(parseInt(ship_obj.battleid), parseInt(ship_obj.playerid), parseInt(ship_obj.xpos), parseInt(ship_obj.ypos), ship_obj.stype, ship_obj.orientation, true);
			the_ship.afloat = (ship_obj.afloat == 't') ? true : false;
			the_ship.draw(leftCanvas);
		}
	}
}

function listenForUpdates() {
	$.ajax({
		type : 'POST',
		url : '/api/check_shot',
		data : JSON.stringify({
			last_shot : last_shot_received,
			battleid : sessionStorage['battleid'],
			playerid : sessionStorage['playerid']
		}),
		success : receiveUpdate,
		dataType : 'text'
	});
}

function receiveUpdate(response) {
	response = eval('(' + response + ')');
	if (response.success == "false") {
		document.getElementById('mainContent').innerHTML = response.message;
	}
	else {
		if (response.turn != my_turn) {
			if (response.turn == true) {
				alert("It is your turn!");
				my_turn = true;
			}
			else if (response.turn == false) {
				alert("It is not your turn!");
				my_turn = false;
			}
		}
		if (response.message.length > 0) {
			alert(response.message);
		}
		receiveShots(response.content);
	}
	setTimeout(listenForUpdates, 5000);
}

function receiveShots(shot_list) {
	var i;
	for (i = 0; i < shot_list.length; i++) {
		var shot_obj = shot_list[i];
		var the_shot = new Shot(parseInt(shot_obj.battleid), parseInt(shot_obj.playerid), parseInt(shot_obj.xpos), parseInt(shot_obj.ypos), shot_obj.hit, parseInt(shot_obj.id));
		the_shot.hit = (the_shot.hit == 't') ? true : false;
		if(the_shot.playerid == sessionStorage['playerid']) {
			the_shot.draw(rightCanvas);
		} else {
			the_shot.draw(leftCanvas);
		}
		last_shot_received = the_shot.id;
	}
}

/*
 * This functions gets the position of the mouse click on the canvas
 */
function getClickPosition(event, canvas) {
	return canvas.relMouseCoords(event);
}

/*
 * Helper function to compute the mouse click position relative
 * to the canvas.
 * 
 * THIS CODE COURTESY OF: Ryan Artecona
 * FROM: http://stackoverflow.com/questions/55677/how-do-i-get-the-coordinates-of-a-mouse-click-on-a-canvas-element
 */
function relMouseCoords(event){
    var totalOffsetX = 0;
    var totalOffsetY = 0;
    var canvasX = 0;
    var canvasY = 0;
    var currentElement = this;

    do{
        totalOffsetX += currentElement.offsetLeft;
        totalOffsetY += currentElement.offsetTop;
    }
    while(currentElement = currentElement.offsetParent)

    canvasX = event.pageX - totalOffsetX;
    canvasY = event.pageY - totalOffsetY;

    return {x:canvasX, y:canvasY}
}
HTMLCanvasElement.prototype.relMouseCoords = relMouseCoords;
