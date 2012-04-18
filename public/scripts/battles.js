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
	response = eval('(' + response + ')');
	var mainContent = document.getElementById('mainContent');
	var newTable = document.createElement("table");
	newTable.innerHTML = "<thead><tr><th>Opponent</th><th>Start Date</th><th>End Date</th></tr></thead>";
	
	var i;
	for (i=0; i<response.length; i++) {
		var newRow = document.createElement("tr");
		newRow.innerHTML = "<td>" + response[i].playerid + "</td><td>" + response[i].startdate + "</td><td>" + response[i].enddate + "</td>";
		newTable.appendChild(newRow);
	}
	mainContent.appendChild(newTable);
}

function myBattlesReqFail(error) {
	document.getElementById('mainContent').innerHTML += "<p>An error occured retrieving your battles from the server.</p>";
}
