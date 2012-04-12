
window.onload = function () {
	document.getElementById('login').addEventListener('click', login, false);
	document.getElementById('password').addEventListener('keyup', enterLogin, false);
}

function enterLogin(event) {
	if (event.keyCode == 13) {
		login();
	}
}

function login (event) {
	var email = document.getElementById('email').value;
	var password = document.getElementById('password').value;
	var dataString = 'email=' + email + '&password=' + password;
	$.ajax({
	  type: 'POST',
	  url: '/api/login',
	  data: dataString,
	  success: login_response,
	  dataType: 'text'
	});
}

function login_response(response) {
	var result = eval('(' + response + ')');
	if (result.success == true) {
		localStorage['playerid'] = result.userid;
		document.getElementById('mainContent').innerHTML="<p>Login successful!</p>";
	}
	else {
		document.getElementById('mainContent').innerHTML="<p>Login failed!</p>";
	}
}
