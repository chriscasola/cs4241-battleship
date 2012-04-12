/*
 * This file provides the functions that initialize
 * the game boards
 */

var Columns = new Array();
var Rows = new Array();
var opponentCanvas;
var myCanvas;

function initCanvas () {
	// Find the canvas elements
	opponentCanvas = document.getElementById('opponentBoard');
	myCanvas = document.getElementById('myBoard');
	
	// Draw grids on both canvases
	initGrid(myCanvas, "#000000", 10);
	initGrid(opponentCanvas, "#000000", 10);
	
	// Add event listener for click events on the canvas
	myCanvas.addEventListener("mouseup", canvasClick, false);
	
	// Set battle information
	localStorage['battleid'] = "1";
	localStorage['playerid'] = "1";
}

/*
 * Draws a grid on the given canvas in the given color
 * and with the specified size number of rows and columns.
 */
function initGrid(canvas, color, size) {
	// calculate where the grid lines should be placed
	computeLineLocations(size, canvas.width, Columns);
	computeLineLocations(size, canvas.height, Rows);
	
	// draw the lines on the canvas
	drawLines(canvas, Columns, color, "vertical");
	drawLines(canvas, Rows, color, "horizontal");
}

/*
 * Draws the given list of lines on the given canvas with
 * the given orientation and color.  The list should be a
 * list of type Line.
 */
function drawLines(canvas, lineList, color, orientation) {
	var context = canvas.getContext("2d");
	context.strokeStyle = color;
	context.lineWidth = 2;
	
	var i;
	for (i = 0; i < lineList.length; i++) {
		context.beginPath();
		if (orientation == "vertical") {
			context.moveTo(lineList[i].position, 0);
			context.lineTo(lineList[i].position, canvas.height);
		}
		else {
			context.moveTo(0, lineList[i].position);
			context.lineTo(canvas.width, lineList[i].position);
		}
		context.stroke();
	}
}

/*
 * Determines where each line should be placed given
 * the number of lines and the width of the canvas.  It stores the
 * horizontal position of each of these lines in the Choices array.
 */
function computeLineLocations(numLines, canvasDim, lineList) {
	lineList.push(new Line(0));

	var dx = canvasDim / numLines;
	var currPos = 0;
	
	while (numLines > 0) {
		currPos += dx;
		lineList.push(new Line(currPos));
		numLines--;
	}
	lineList.push(new Line(canvasDim));
}
