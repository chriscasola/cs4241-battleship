/**
 * Deals with generating and regenerating the menu bar.
 * 
 * @author Chris Casola
 * @author Chris Page
 */

/**
 * Stores what the current page is.
 */
var MenuCurrentPage;

/**
 * The html for the menu bar.
 */
var menuBarHTML =	'<nav>' + 
					'	<ul id="menuBarList">' + 
					'	</ul>' + 
					'</nav>';

/*
 * Menu items and their links
 */
var sectionNames = [
	{title: "Home", href: "/index.html", loggedInOnly: false},
	{title: "About", href: "/about.html", loggedInOnly: false},
	{title: "Leaderboard", href: "/leaderboard.html", loggedInOnly: false},
	{title: "My Battles", href: "/mybattles.html", loggedInOnly: true}
];

var extraButtons = [
	{title: "Login", href: null, onclick: "showLoginOverlay()"},
	{title: "Register", href: null, onclick: "showRegisterOverlay()"}
];

/**
 * Adds the list items that appear on the left side of the menu.
 */
function fillTopMenuWithSections() {
	var elMenuBarList = document.getElementById("menuBarList");
	var i;
	
	for (i=0; i < sectionNames.length; i++) {
		if ((sectionNames[i].loggedInOnly && userIsLoggedIn()) || 
			!sectionNames[i].loggedInOnly) {
			var newSectionLi = document.createElement("li");
			var newSectionLiA = document.createElement("a");
			var newSectionLiAP = document.createElement("p");
			
			newSectionLiAP.innerHTML = sectionNames[i].title;
			
			newSectionLiA.appendChild(newSectionLiAP);
			newSectionLiA.setAttribute("href", sectionNames[i].href);
			
			newSectionLi.appendChild(newSectionLiA);
			
			if (MenuCurrentPage == sectionNames[i].title) {
				newSectionLi.setAttribute("class","activePage");
			}
			
			elMenuBarList.appendChild(newSectionLi);
		}
	}
}

/**
 * Decides whether or not the username or the login and register buttons 
 * should be displayed and then adds them to the menu bar.
 */
function fillTopMenuRightSide() {
	if (userIsLoggedIn()) {
		fillTopMenuRightSideUserStuff();
	}
	else {
		fillTopMenuRightSideButtons();
	}
}

/**
 * Adds the username and a logout link to the right side of the menu.
 */
function fillTopMenuRightSideUserStuff() {
	var elMenuBarList = document.getElementById("menuBarList");
	
	var elUsernameLi = document.createElement("li");
	var elUsernameLiA = document.createElement("a");
	var elLogoutLi = document.createElement("li");
	var elLogoutLiA = document.createElement("a");
	
	elUsernameLiA.setAttribute('href', '/userconfig.html');
	elUsernameLiA.innerHTML = "<p id='userNameLabel'>" + sessionStorage['playername'] + "</p>";
	
	elUsernameLi.appendChild(elUsernameLiA);
	elUsernameLi.setAttribute("id", "menuUsername");
	elUsernameLi.setAttribute("class", "rightSide");
	
	elLogoutLiA.innerHTML = "<p>Logout</p>";
	elLogoutLiA.setAttribute("onclick", "doLogout()");
	
	elLogoutLi.appendChild(elLogoutLiA);
	elLogoutLi.setAttribute("id", "menuLogout");
	elLogoutLi.setAttribute("class", "rightSide");
	
	elMenuBarList.appendChild(elLogoutLi);
	elMenuBarList.appendChild(elUsernameLi);
}

/**
 * Adds the list items that appear on the right side of the menu.
 */
function fillTopMenuRightSideButtons() {
	var elMenuBarList = document.getElementById("menuBarList");
	var i;
	
	for (i=0; i < extraButtons.length; i++) {
		var newSectionLi = document.createElement("li");
		var newSectionLiA = document.createElement("a");
		var newSectionLiAP = document.createElement("p");
		
		newSectionLiAP.innerHTML = extraButtons[i].title;
		
		newSectionLiA.appendChild(newSectionLiAP);
		
		if (extraButtons[i].href != null) {
			newSectionLiA.setAttribute("href", extraButtons[i].href);
		}
		if (extraButtons[i].onclick != null) {
			newSectionLiA.setAttribute("onclick", extraButtons[i].onclick);
		}
		
		newSectionLi.appendChild(newSectionLiA);
		
		newSectionLi.setAttribute("class", "rightSide");
		
		elMenuBarList.appendChild(newSectionLi);
	}
}

/**
 * Generates the top menu.
 */
function generateTopMenu() {
	document.write(menuBarHTML);
	
	fillTopMenuWithSections();
	fillTopMenuRightSide();
}

/**
 * Regenerates the contents of the unordered list in the nav element.
 */
function regenerateTopMenu() {
	var elMenuBarList = document.getElementById("menuBarList");
	
	elMenuBarList.innerHTML = "";
	
	fillTopMenuWithSections();
	fillTopMenuRightSide();
}

/**
 * Sets the value of the MenuCurrentPage variable. This variable is used to 
 * highlight the correct menu item when it is generated.
 * 
 * @param currentPage
 */
function setMenuCurrentPage(currentPage) {
	MenuCurrentPage = currentPage;
}

/**
 * Checks if the user is logged in.
 */
function userIsLoggedIn() {
	return !(sessionStorage['playerid'] == undefined);
}

function getCurrPage() {
	var regexp = /^\/?(\w*)/;
	var pageName = regexp.exec(window.location.pathname)[1];
	if (pageName == "index") return "Home";
	pageName = pageName.charAt(0).toUpperCase() + pageName.slice(1);
	return pageName;
}
