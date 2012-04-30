/*
 * File to display battles a user is involved with on the "My Battles" page
 *
 * Author: Chris Casola
 * Author: Chris Page
 *
 */

var mybattles = {};
var newBattle = false;

window.onload = function() {	
	if (sessionStorage['playerid'] == undefined) { /* the user is not logged in, alert them */
		var mainContent = document.getElementById('mainContent');
		var newElement = document.createElement("p");
		newElement.innerHTML = "You need to login to see your battles.";
		mainContent.appendChild(newElement);
	} 
	else {
		initPage(); /* add the create battle section to the page */
		getBattles(); /* retrieve the user's battles from the server */
		waitForOpponent(); /* start polling to listen for new battles */
	}
}

/*
 * Make a request for the user's battles
 */
function getBattles() {
	$.ajax({
		type : 'GET',
		url : '/api/my_battles',
		success : displayBattles,
		error : myBattlesReqFail,
	});
}

/*
 * Add the basic UI items to the page
 */
function initPage() {
	var mainContent = document.getElementById('mainContent');
	mainContent.innerHTML = "<h1>My Battles</h1>";
	var createBattleButton = document.createElement('p');
	createBattleButton.innerHTML = 'Begin a New Battle';
	createBattleButton.setAttribute('id', 'createBattle');
	var battleForm = document.createElement('section');
	battleForm.setAttribute('id', 'createBattleForm');
	mainContent.appendChild(createBattleButton);
	mainContent.appendChild(battleForm);
	document.getElementById('createBattle').style.cursor="pointer";
	document.getElementById('createBattle').addEventListener("click", showCreateBattleForm, false);
}

/*
 * Add each battle to the My Battles table
 */
function displayBattles(response) {
	if (response == 'not logged in') {
		document.getElementById('mainContent').innerHTML = "You are not logged in!";
	}
	mybattles = response;
	response = eval('(' + response + ')');
	var mainContent = document.getElementById('mainContent');
	var newTable = document.createElement("table");
	newTable.setAttribute('id', 'battleTable');
	newTable.innerHTML = "<thead><tr><th>Opponent</th><th>Start Date</th><th>Status</th></tr></thead>";
	
	var i;
	for (i=0; i<response.length; i++) {
		var newRow = document.createElement("tr");
		newRow.innerHTML = "<td>" + response[i].playerid + "</td><td>" + convertDateTime(response[i]) + "</td><td>" + response[i].status + "</td>";
		if (newBattle && (i==0)) {
			newRow.setAttribute('class', 'newBattle');
		}
		newTable.appendChild(newRow);
		newRow.addEventListener("click", onClickBattleRow, false);
		newRow.setAttribute("battleid", response[i].battleid);
		newRow.style.cursor="pointer";
	}
	mainContent.appendChild(newTable);
}

/*
 * Cause the CreateBattleForm to appear when the user clicks "Begin a new Battle"
 */
function showCreateBattleForm(event) {
	var battleForm = document.getElementById('createBattleForm');
	battleForm.innerHTML = "<p>Battle with: <input type='text' id='oppName' /><input type='button' value='Start battle' id='startBattle' /></p>";
	battleForm.innerHTML += "<p><input type='button' value='Find an online player' name='findOnline' id='findOnline'/></p>";
	document.getElementById('createBattle').setAttribute('hidden', 'true');
	document.getElementById('startBattle').addEventListener('click', createBattle, false);
	document.getElementById('findOnline').addEventListener('click', findPlayer, false);
}

/*
 * Request a match be found for the player
 */
function findPlayer() {
	$.ajax({
		type : 'POST',
		url : '/api/find_battle',
	});
	initPage();
	displayBattles(mybattles);
}

/*
 * Poll for any new battles the player is invited to
 */
function waitForOpponent() {
	$.ajax({
		type : 'GET',
		url : '/api/update_matches',
		success: checkForBattles
	});
}

/*
 * React to responses from the server that may or may not
 * indicate a new battle has been created
 */
function checkForBattles(response) {
	response = eval('(' + response + ')');
	var battleTable = document.getElementById('battleTable');
	if (response.length > 0) {
		for (var i = 0; i < response.length; i++) {
			if (response[i].invite == 't') {
				window.newAlert('You have been invited to a battle!');
			}
			else {
				window.newAlert('We found you a match!');
			}
			newBattle = true;
		}
		initPage();
		getBattles();
	}
	setTimeout(waitForOpponent, 5000);
}

/*
 * Creates a new battle with the player id input by the user
 */
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
		newAlert('The opponent name you entered is invalid');
	}
	else {
		window.location.href = '/mybattles.html';
	}
}

/*
 * Moves to the battle page when the user clicks on a battle
 */
function onClickBattleRow(event) {
	sessionStorage['battleid'] = event.currentTarget.getAttribute('battleid');
	sessionStorage['opponentName'] = event.currentTarget.children[0].innerHTML;
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
