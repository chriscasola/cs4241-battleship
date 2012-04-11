/*
 * This file provides the functions that deal with
 * the user's interaction with the game boards
 */

function canvasClick(event) {
	// get location where the user clicked
	var clickPos = getClickPosition(event, event.target);
	
	// construct a Shot representing this click
	var thisShot = new Shot(localStorage['battleid'], localStorage['playerid'], clickPos.x, clickPos.y, false);
	thisShot.mouseToCell();
	
	// send the shot to the server and draw the shot upon response
	thisShot.send();
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