/*
 * File to display battles a user is involved with
 * 
 * Author: Chris Casola
 * Author: Chris Page
 * 
 */

window.onload = function () {
	if (sessionStorage['playerid'] == undefined) {
		document.getElementById('mainContent').innerHTML="<p>You need to login to see your battles.</p>";
	}
	else {
		document.getElementById('mainContent').innerHTML="<h1>My Battles</h1>";
	}
}
