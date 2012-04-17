/**
 * TODO This comment.
 * 
 * TODO Work on the overlay some more. Need to be able to close it after registration. Need to fix formatting.
 * 
 * @author Chris Page
 */

RegisterBoxHTML =	'	<h1>Register</h1>' +
				'	<a id="closeRegisterBox" onclick="removeRegisterOverlay()">X</a>' + 
				'   </table>' +
				'	<br />' + 
				'	<div>' + 
				'		<table>' + 
				'			<tr>' + 
				'				<td>' + 
				'					<label for="registerEmail">Email: </label>' + 
				'				</td>' + 
				'				<td>' + 
				'					<input type="text" id="registerEmail" name="email" />' + 
				'				</td>' + 
				'			</tr>' + 
				'			<tr>' + 
				'				<td>' + 
				'					<label for="registerPassword1">Password: </label>' + 
				'				</td>' + 
				'				<td>' + 
				'					<input type="password" id="registerPassword1" name="password1" />' + 
				'				</td>' + 
				'			</tr>' + 
				'			<tr>' + 
				'				<td>' + 
				'					<label for="registerPassword2">Confirm Password: </label>' + 
				'				</td>' + 
				'				<td>' + 
				'					<input type="password" id="registerPassword2" name="password2" />' + 
				'				</td>' + 
				'			</tr>' + 
				'			<tr>' + 
				'				<td>' + 
				'					<label for="registerName">Name: </label>' + 
				'				</td>' + 
				'				<td>' + 
				'					<input type="text" id="registerName" name="name" />' + 
				'				</td>' + 
				'			</tr>' + 
				'		</table>' + 
				'		<input type="button" id="register" onclick="doRegister()" value="Register" />' + 
				'		<p id="registerError"></p>' + 
				'	</div>';
				

/**
 * @see http://answers.oreilly.com/topic/1823-adding-a-page-overlay-in-javascript/
 */
function showRegisterOverlay() {
	var overlay = document.createElement("div");
	overlay.setAttribute("id","registerOverlay");
	overlay.setAttribute("class", "overlay");
	document.body.appendChild(overlay);
	
	var registerBox = document.createElement("div");
	registerBox.setAttribute("id","registerBox");
	registerBox.innerHTML = RegisterBoxHTML;
	document.body.appendChild(registerBox);
}

/**
 * @see http://answers.oreilly.com/topic/1823-adding-a-page-overlay-in-javascript/
 */
function removeRegisterOverlay() {
	document.body.removeChild(document.getElementById("registerOverlay"));
	document.body.removeChild(document.getElementById("registerBox"));
}

/**
 * Disables the register inputs.
 */
function disableRegisterInput() {
	var elRegisterEmail = document.getElementById("registerEmail");
	var elRegisterPassword1 = document.getElementById("registerPassword1");
	var elRegisterPassword2 = document.getElementById("registerPassword2");
	var elRegisterName = document.getElementById("registerName");
	var elRegister = document.getElementById("register");
	
	elRegisterEmail.setAttribute("disabled", "disabled");
	elRegisterPassword1.setAttribute("disabled", "disabled");
	elRegisterPassword2.setAttribute("disabled", "disabled");
	elRegisterName.setAttribute("disabled", "disabled");
	elRegister.setAttribute("disabled", "disabled");
}

/**
 * Enables the register inputs.
 */
function enableRegisterInput() {
	var elRegisterEmail = document.getElementById("registerEmail");
	var elRegisterPassword1 = document.getElementById("registerPassword1");
	var elRegisterPassword2 = document.getElementById("registerPassword2");
	var elRegisterName = document.getElementById("registerName");
	var elRegister = document.getElementById("register");
	
	elRegisterEmail.removeAttribute("disabled");
	elRegisterPassword1.removeAttribute("disabled");
	elRegisterPassword2.removeAttribute("disabled");
	elRegisterName.removeAttribute("disabled");
	elRegister.removeAttribute("disabled");
}

/**
 * This function takes the information in the input boxes and uses it to register.
 * 
 * Taken from Chris Casola's code.
 */
function doRegister (event) {
	disableRegisterInput();
	
	// get email
	var email = document.getElementById('registerEmail').value;
	// get password
	var password1 = document.getElementById('registerPassword1').value;
	// get password confirmation
	var password2 = document.getElementById('registerPassword2').value;
	// get name
	var name = document.getElementById('registerName').value;
	
	// construct the data to POST to /api/register
	var dataString = 'email=' + email + '&password1=' + password1 + "&password2=" + password2 + "&name=" + name;
	$.ajax({
	  type: 'POST',
	  url: '/api/register',
	  data: dataString,
	  success: register_response,
	  dataType: 'text'
	});
}

/**
 * Handles the response from /api/register.
 * 
 * Taken from Chris Casola's code.
 * 
 * @param response The response from the jquery ajax.
 */
function register_response(response) {
	var result = eval('(' + response + ')');
	if (result.success == true) {
		localStorage['playerid'] = result.userid;
		document.getElementById('registerError').innerHTML="<p>Registration successful!</p>";
		removeRegisterOverlay();
	}
	else {
		document.getElementById('registerError').innerHTML="<p>Registration failed! Error recieved: " + result.error + "</p>";
		enableRegisterInput();
	}
}
