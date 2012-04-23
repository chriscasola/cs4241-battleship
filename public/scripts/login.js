/**
 * This allows the user to login.
 * 
 * @author Chris Page
 */

LoginBoxHTML =	'	<h1>Login</h1>' +
				'	<a id="closeLoginBox" onclick="removeLoginOverlay()">X</a>' + 
				'   </table>' +
				'	<br />' + 
				'	<div>' + 
				'		<table>' + 
				'			<tr>' + 
				'				<td>' + 
				'					<label for="loginEmail">Email: </label>' + 
				'				</td>' + 
				'				<td>' + 
				'					<input type="text" id="loginEmail" name="email" />' + 
				'				</td>' + 
				'			</tr>' + 
				'			<tr>' + 
				'				<td>' + 
				'					<label for="loginPassword">Password: </label>' + 
				'				</td>' + 
				'				<td>' + 
				'					<input type="password" id="loginPassword" name="password" />' + 
				'				</td>' + 
				'			</tr>' + 
				'		</table>' + 
				'		<input type="button" id="login" onclick="doLogin()" value="Login" />' + 
				'		<p id="loginError"></p>' + 
				'	</div>';
				

/**
 * @see http://answers.oreilly.com/topic/1823-adding-a-page-overlay-in-javascript/
 */
function showLoginOverlay() {
	var overlay = document.createElement("div");
	overlay.setAttribute("id","loginOverlay");
	overlay.setAttribute("class", "overlay");
	document.body.appendChild(overlay);
	
	var loginBox = document.createElement("div");
	loginBox.setAttribute("id","loginBox");
	loginBox.innerHTML = LoginBoxHTML;
	document.body.appendChild(loginBox);
}

/**
 * @see http://answers.oreilly.com/topic/1823-adding-a-page-overlay-in-javascript/
 */
function removeLoginOverlay() {
	document.body.removeChild(document.getElementById("loginOverlay"));
	document.body.removeChild(document.getElementById("loginBox"));
}

/**
 * Disables the login inputs.
 */
function disableLoginInput() {
	var elLoginEmail = document.getElementById("loginEmail");
	var elLoginPassword = document.getElementById("loginPassword");
	var elLogin = document.getElementById("login");
	
	elLoginEmail.setAttribute("disabled", "disabled");
	elLoginPassword.setAttribute("disabled", "disabled");
	elLogin.setAttribute("disabled", "disabled");
}

/**
 * Enables the login inputs.
 */
function enableLoginInput() {
	var elLoginEmail = document.getElementById("loginEmail");
	var elLoginPassword = document.getElementById("loginPassword");
	var elLogin = document.getElementById("login");
	
	elLoginEmail.removeAttribute("disabled");
	elLoginPassword.removeAttribute("disabled");
	elLogin.removeAttribute("disabled");
}

/**
 * This function takes the information in the input boxes and uses it to login.
 * 
 * Taken from Chris Casola's code.
 */
function doLogin (event) {
	disableLoginInput();
	
	// get email
	var email = document.getElementById('loginEmail').value;
	// get password
	var password = document.getElementById('loginPassword').value;
	
	// construct the data to POST to /api/login
	var dataString = 'email=' + email + '&password=' + password;
	$.ajax({
	  type: 'POST',
	  url: '/api/login',
	  data: dataString,
	  success: login_response,
	  dataType: 'text'
	});
}

/**
 * Handles the response from /api/login.
 * 
 * Taken from Chris Casola's code.
 * 
 * @param response The response from the jquery ajax.
 */
function login_response(response) {
	var result = eval('(' + response + ')');
	if (result.success == true) {
		sessionStorage['playerid'] = result.userid;
		sessionStorage['playername'] = result.name;
		document.getElementById('loginError').innerHTML="<p>Login successful!</p>";
		removeLoginOverlay();
		regenerateTopMenu();
	}
	else {
		document.getElementById('loginError').innerHTML="<p>Login failed! Error recieved: " + result.error + "</p>";
		enableLoginInput();
	}
}
