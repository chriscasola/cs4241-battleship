/*
 * This file provides the functions that deal with
 * the user's interaction with the game boards
 */

var last_shot_received = 0;

function canvasClick(event) {
	// get location where the user clicked
	var clickPos = getClickPosition(event, event.target);
	
	// construct a Shot representing this click
	var thisShot = new Shot(localStorage['battleid'], localStorage['playerid'], clickPos.x, clickPos.y, false, 0);
	thisShot.mouseToCell();
	
	// send the shot to the server and draw the shot upon response
	thisShot.send();
}

function listenForMoves() {
	$.ajax({
	  type: 'POST',
	  url: '/api/check_shot',
	  data: last_shot_received.toString(),
	  success: receiveOtherShot,
	  dataType: 'text'
	});
}

function receiveOtherShot(response) {
	if (response != 'none') {
		shot_list = eval('(' + response + ')');
		
		var i;
		for (i = 0; i < shot_list.length; i++) {
			var shot_obj = shot_list[i];
			var the_shot = new Shot(parseInt(shot_obj.battleid), parseInt(shot_obj.playerid), parseInt(shot_obj.xpos), parseInt(shot_obj.ypos), shot_obj.hit, parseInt(shot_obj.id));
			the_shot.hit = (the_shot.hit == 't') ? true : false;
			if (the_shot.playerid == localStorage['playerid']) {
				the_shot.draw(document.getElementById('myBoard'));
			}
			else {
				the_shot.draw(document.getElementById('opponentBoard'));
			}
			last_shot_received = the_shot.id;
		}
	}
	setTimeout(listenForMoves, 5000);
}

/*
 * This functions gets the position of the mouse click
 */
function getClickPosition(event, canvas) {
	if (event.x != undefined && event.y != undefined) {
		x = event.x;
		y = event.y;
	}
	else { /* code to work with Firefox */
		x = event.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
		y = event.clientY + document.body.scrollTop + document.documentElement.scrollTop;
	}	
	x -= canvas.offsetLeft;
	y -= canvas.offsetTop;
	var clickPos = {x: x, y: y};
	return clickPos;
}