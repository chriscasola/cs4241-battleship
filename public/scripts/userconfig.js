/**
 * This allows the user to update zer info.
 * 
 * @author Chris Page
 */

var myUserConfig = new UserConfig();

/**
 * TODO This comment
 */
function UserConfig () {
	/**
	 * Disables the userconfig inputs.
	 */
	this.disableUserConfigInput = function () {
		var elCPassword = document.getElementById("cPassword");
		var elNPassword1 = document.getElementById("nPassword1");
		var elNPassword2 = document.getElementById("nPassword2");
		var elNEmail1 = document.getElementById("nEmail1");
		var elNEmail2 = document.getElementById("nEmail2");
		var elNName = document.getElementById("nName");
		var elNIconId = document.getElementById("nIconId");
		var elUserConfigSubmit = document.getElementById("UserConfigSubmit");
		
		elCPassword.setAttribute("disabled", "true");
		elNPassword1.setAttribute("disabled", "true");
		elNPassword2.setAttribute("disabled", "true");
		elNEmail1.setAttribute("disabled", "true");
		elNEmail2.setAttribute("disabled", "true");
		elNName.setAttribute("disabled", "true");
		elNIconId.setAttribute("disabled", "true");
		elUserConfigSubmit.setAttribute("disabled", "true");
	}
	
	/**
	 * Enables the userconfig inputs.
	 */
	this.enableUserConfigInput = function () {
		var elCPassword = document.getElementById("cPassword");
		var elNPassword1 = document.getElementById("nPassword1");
		var elNPassword2 = document.getElementById("nPassword2");
		var elNEmail1 = document.getElementById("nEmail1");
		var elNEmail2 = document.getElementById("nEmail2");
		var elNName = document.getElementById("nName");
		var elNIconId = document.getElementById("nIconId");
		var elUserConfigSubmit = document.getElementById("UserConfigSubmit");
		
		elCPassword.removeAttribute("disabled");
		elNPassword1.removeAttribute("disabled");
		elNPassword2.removeAttribute("disabled");
		elNEmail1.removeAttribute("disabled");
		elNEmail2.removeAttribute("disabled");
		elNName.removeAttribute("disabled");
		elNIconId.removeAttribute("disabled");
		elUserConfigSubmit.removeAttribute("disabled");
	}
	
	/**
	 * This function takes the information in the input boxes and uses it to update the user info.
	 * 
	 * Taken from Chris Casola's code.
	 */
	this.doUpdateUserInfo = function () {
		this.disableUserConfigInput();
		
		// Get values from the inputs
		var cPassword = document.getElementById("cPassword").value;
		var nPassword1 = document.getElementById("nPassword1").value;
		var nPassword2 = document.getElementById("nPassword2").value;
		var nEmail1 = document.getElementById("nEmail1").value;
		var nEmail2 = document.getElementById("nEmail2").value;
		var nName = document.getElementById("nName").value;
		var nIconId = document.getElementById("nIconId").value;
		
		// construct the data to POST to /api/login
		var dataString = 'cPassword=' + cPassword + 
						'&nPassword1=' + nPassword1 + 
						'&nPassword2=' + nPassword1 + 
						'&nEmail1=' + nEmail1 + 
						'&nEmail2=' + nEmail2 + 
						'&nName=' + nName + 
						'&nIconId=' + nIconId;
		$.ajax({
		  type: 'POST',
		  url: '/user/update',
		  data: dataString,
		  success: this.userconfig_response,
		  dataType: 'text'
		});
	}
	
	/**
	 * Handles the response from /user/update.
	 * 
	 * Taken from Chris Casola's code.
	 * 
	 * @param response The response from the jquery ajax.
	 */
	this.userconfig_response = function (response) {
		var result = eval('(' + response + ')');
		
		if (result.success == true) {
			document.getElementById('errorUserConfig').innerHTML="<p>Information update successful!</p>";
			removeLoginOverlay();
			regenerateTopMenu();
		}
		else {
			document.getElementById('errorUserConfig').innerHTML="<p>Information update failed! Error recieved: " + result.error + "</p>";
		}
		this.enableUserConfigInput();
	}
}
