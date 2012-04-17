/*
 * This file provides the functions that deal with
 * the user's interaction with the game boards
 */

var last_shot_received = 0;

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

function getShips() {
	$.ajax({
		type : 'POST',
		url : '/api/get_ships',
		data : JSON.stringify({
			battleid : sessionStorage['battleid'],
			playerid : sessionStorage['playerid']
		}),
		success : receiveShips,
		dataType : 'text'
	});
}

function receiveShips(response) {
	if(response != 'none') {
		ship_list = eval('(' + response + ')');

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
	resp_obj = eval('(' + response + ')');

	switch (resp_obj.type) {
		case 'info':
			// do nothing
			break;

		case 'shot':
			receiveOtherShot(resp_obj.content);
			if (resp_obj.content[0].message == 'lost') {
				alert("You lost the game!");
			}
			break;
	}
	setTimeout(listenForUpdates, 5000);
}

function receiveOtherShot(shot_list) {
	var i;
	for( i = 1; i < shot_list.length; i++) {
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
 * This functions gets the position of the mouse click
 */
function getClickPosition(event, canvas) {
	if(event.x != undefined && event.y != undefined) {
		x = event.x;
		y = event.y;
	} else {/* code to work with Firefox */
		x = event.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
		y = event.clientY + document.body.scrollTop + document.documentElement.scrollTop;
	}
	x -= canvas.offsetLeft;
	y -= canvas.offsetTop;
	var clickPos = {
		x : x,
		y : y
	};
	return clickPos;
}