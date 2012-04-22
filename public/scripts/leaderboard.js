/**
 * This handles the ajax leaderboard on the leaderboard webpage.
 * 
 * @author Chris Page
 */

window.onload = populateLeaderboard;

/**
 * Makes a call to the server to get the data for populating the leaderboard.
 */
function populateLeaderboard() {
	$.ajax({
	  type: 'POST',
	  url: '/api/leaderboard',
	  success: leaderboard_response,
	  dataType: 'text'
	});
}

/**
 * Handles the response from the server and populates the leaderboard.
 */
function leaderboard_response(response) {
	var elTbody = document.getElementById("leaderboardTbody");
	
	var rows = JSON.parse(response);
	
	for (var i = 0; i < rows.length; i++) {
		var html_row = document.createElement("tr");
		var html_cell_rank = document.createElement("td");
		var html_cell_name = document.createElement("td");
		var html_cell_numwins = document.createElement("td");
		
		html_cell_rank.innerHTML = i+1;
		html_cell_name.innerHTML = rows[i].name;
		html_cell_numwins.innerHTML = rows[i].numwins;
		
		html_row.appendChild(html_cell_rank);
		html_row.appendChild(html_cell_name);
		html_row.appendChild(html_cell_numwins);
		
		elTbody.appendChild(html_row);
	}
}
