/*
 * File to enable alerts that appear on the web page
 * rather than as popup windows.
 * 
 * Author: Chris Casola
 */

/*
 * Function to override the default alert function
 */
(function() {
	window.newAlert = function(message) {
		document.getElementById('alert').innerHTML = message; /* Set the inner text of the alert paragraph to the given message */
		document.getElementById('alert').style.opacity = 100; /* Make the alert visible on the page */
		setTimeout(function() { document.getElementById('alert').style.opacity = 0 }, 1000 * 8); /* hide the alert after 8 seconds */
	}
}).call();
