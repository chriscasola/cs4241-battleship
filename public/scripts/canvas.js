
function initCanvas () {

	var opponentView = document.getElementById('opponentBoard').getContext("2d");
	var myView = document.getElementById('myBoard').getContext("2d");
	
	var height = opponentView.canvas.height;
	var width = myView.canvas.width;
	
	drawGrid(opponentView, "#000000", 1, 10, 10, width, height);
	drawGrid(myView, "#000000", 1, 10, 10, width, height);
	
	document.getElementById('opponentBoard').addEventListener("mouseup", makeMove, false);
	document.getElementById('myBoard').addEventListener("mouseup", makeMove, false);
}

function makeMove(event) {
	var x;
	var y;
	canvas = event.target;
	
	if (event.x != undefined && event.y != undefined) {
		x = event.x;
		y = event.y;
	}
	else { /* code for firefox */
		x = event.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
		y = event.clientY + document.body.scrollTop + document.documentElement.scrollTop;
	}
	
	x -= canvas.offsetLeft;
	y -= canvas.offsetTop;
	
	var shotCell = pixelsToCell(x, y, 350 / 10, 350 / 10);
	var shotPos = cellToPixels(shotCell.col, shotCell.row, 350 / 10, 350 / 10);
	
	drawShot(canvas.getContext("2d"), 'red', shotPos.x, shotPos.y);
	
	//alert("x: " + x + " y: " + y);
}

function drawShot(context, color, xPos, yPos) {	
	context.fillStyle = color;
	context.beginPath();
	context.arc(xPos, yPos, 10, 0, 2 * Math.PI);
	context.closePath();
	context.fill();
	context.stroke();
}

function drawGrid(context, color, width, numCols, numRows, cWidth, cHeight) {	
	context.strokeStyle = color;
	context.lineWidth = width;
	
	var currXPos;
	for (currXPos = 0.5; currXPos <= cWidth; currXPos += Math.floor((cWidth / numCols))) {
		context.beginPath();
		context.moveTo(currXPos, 0);
		context.lineTo(currXPos, 350);
		context.stroke();
	}
	
	var currYPos;	
	for (currYPos = 0.5; currYPos <= cHeight; currYPos += Math.floor((cHeight / numRows))) {
		context.beginPath();
		context.moveTo(0, currYPos);
		context.lineTo(350, currYPos);
		context.stroke();
	}
}

function cellToPixels(col, row, width, height) {
	var pixels = {x: 0, y: 0};
	pixels.x = (width * col) - Math.floor((width / 2));
	pixels.y = (height * row) - Math.floor((height / 2));
	return pixels;
}

function pixelsToCell(xPos, yPos, width, height) {
	var cell = {col: 0, row: 0};
	cell.col = Math.floor((xPos / width) + .5);
	cell.row = Math.floor((yPos / height) + .5);
	return cell;
}

