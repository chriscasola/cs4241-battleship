/*
 * File to display battles a user is involved with
 *
 * Author: Chris Casola
 * Author: Chris Page
 *
 */

window.onload = function() {	
	if (sessionStorage['playerid'] == undefined) {
		var mainContent = document.getElementById('mainContent');
		var newElement = document.createElement("p");
		newElement.innerHTML = "You need to login to see your battles.";
		mainContent.appendChild(newElement);
	} 
	else {
		$.ajax({
			type : 'GET',
			url : '/api/my_battles',
			success : displayBattles,
			error : myBattlesReqFail,
		});
	}
}

function displayBattles(response) {
	if (response == 'not logged in') {
		document.getElementById('mainContent').innerHTML = "You are not logged in!";
	}
	response = eval('(' + response + ')');
	var mainContent = document.getElementById('mainContent');
	var newTable = document.createElement("table");
	newTable.innerHTML = "<thead><tr><th>Opponent</th><th>Start Date</th><th>Status</th></tr></thead>";
	
	var i;
	for (i=0; i<response.length; i++) {
		var newRow = document.createElement("tr");
		newRow.innerHTML = "<td>" + response[i].playerid + "</td><td>" + convertDateTime(response[i]) + "</td><td>" + response[i].status + "</td>";
		newTable.appendChild(newRow);
		newRow.addEventListener("click", onClickBattleRow, false);
		newRow.setAttribute("battleid", response[i].battleid);
		newRow.style.cursor="pointer";
	}
	mainContent.appendChild(newTable);
}

function onClickBattleRow(event) {
	sessionStorage['battleid'] = event.currentTarget.getAttribute('battleid');
	window.location.href = '/battle.html';
}

function convertDateTime(response) {
	var retVal = "";
	var ampm = ((parseInt(response.shour) / 12) >= 1) ? "pm" : "am";
	retVal += response.smonth + "/" + response.sday + "/" + response.syear + " &mdash; " + parseInt(response.shour)%12 + ":" + response.smin + " " + ampm;
	return retVal;
}

function myBattlesReqFail(error) {
	document.getElementById('mainContent').innerHTML += "<p>An error occured retrieving your battles from the server.</p>";
}
