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
		initPage();
		document.getElementById('createBattle').addEventListener("click", showCreateBattleForm, false);
		
		$.ajax({
			type : 'GET',
			url : '/api/my_battles',
			success : displayBattles,
			error : myBattlesReqFail,
		});
	}
}

function initPage() {
	var mainContent = document.getElementById('mainContent');
	var createBattleButton = document.createElement('p');
	createBattleButton.innerHTML = 'Begin a New Battle';
	createBattleButton.setAttribute('id', 'createBattle');
	var battleForm = document.createElement('section');
	battleForm.setAttribute('id', 'createBattleForm');
	mainContent.appendChild(createBattleButton);
	mainContent.appendChild(battleForm);
	document.getElementById('createBattle').style.cursor="pointer";
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

function showCreateBattleForm(event) {
	var battleForm = document.getElementById('createBattleForm');
	battleForm.innerHTML = "<p>Battle with: <input type='text' id='oppName' /><input type='button' value='Start battle' id='startBattle' /></p>";
	battleForm.innerHTML += "<p><input type='button' value='Find an online player' name='findOnline' /></p>";
	document.getElementById('createBattle').setAttribute('hidden', 'true');
	document.getElementById('startBattle').addEventListener('click', createBattle, false);
}

function createBattle(event) {
	var opponentName = document.getElementById('oppName').value;
	$.ajax({
			type : 'POST',
			url : '/api/create_battle',
			data : opponentName,
			success : showBattle,
			error : myBattlesReqFail,
	});
}

function showBattle(response) {
	if (response == 'invalid') {
		alert('The opponent name you entered is invalid');
	}
	else {
		sessionStorage['battleid'] = response;
		window.location.href = '/battle.html';
	}
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
