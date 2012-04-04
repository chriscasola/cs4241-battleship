
function initCanvas () {
	var ob = document.getElementById('opponentBoard');
	var mb = document.getElementById('myBoard');
	
	var obx = ob.getContext("2d");
	var mbx = mb.getContext("2d");
	
	obx.fillStyle="#000000";
	mbx.fillStyle="#000000";
	
	obx.fillRect(5, 5, 20, 20);
	mbx.fillRect(5, 5, 20, 20);
}
