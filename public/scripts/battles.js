/*
 * File to display battles a user is involved with
 *
 * Author: Chris Casola
 * Author: Chris Page
 *
 */

window.onload = function() {
	document.getElementById('mainContent').innerHTML = "<h1>My Battles</h1>";
	
	if (sessionStorage['playerid'] == undefined) {
		document.getElementById('mainContent').innerHTML += "<p>You need to login to see your battles.</p>";
	} 
	else {
		$.ajax({
			type : 'POST',
			url : '/api/my_battles',
			data : sessionStorage['playerid'],
			success : displayBattles,
			error : myBattlesReqFail,
			dataType : 'text'
		});
	}
}

function displayBattles(response) {
	response = eval('(' + response + ')');
	mainContent = document.getElementById('mainContent');
	mainContent.innerHTML += "<table><thead><tr><th>Opponent</th><th>Start Date</th><th>End Date</th></tr></thead>"
	var i;
	for (i=0; i<response.length; i++) {
		mainContent.innerHTML += "<tr><td>" + response[i].playerid + "</td><td>" + response[i].startdate + "</td><td>" + response[i].enddate + "</td></tr>";
	}
	mainContent.innerHTML += "</table>";
}

function myBattlesReqFail(error) {
	document.getElementById('mainContent').innerHTML += "<p>An error occured retrieving your battles from the server.</p>";
}
