/**
 * TODO This comment.
 * 
 * @author Chris Casola
 * @author Chris Page
 */

var CurrentPage;

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

function fillTopMenuWithSections(currentPage) {
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
			
			if (currentPage == sectionNames[i].title) {
				newSectionLi.setAttribute("class","activePage");
			}
			
			elMenuBarList.appendChild(newSectionLi);
		}
	}
}

function fillTopMenuRightSide() {
	if (userIsLoggedIn()) {
		fillTopMenuRightSideUserStuff();
	}
	else {
		fillTopMenuRightSideButtons();
	}
}

function fillTopMenuRightSideUserStuff() {
	
}

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

function generateTopMenu(currentPage) {
	CurrentPage = currentPage;
	document.write(menuBarHTML);
	
	fillTopMenuWithSections(currentPage);
	fillTopMenuRightSide();
}

function refreshTopMenu() {
	var elMenuBarList = document.getElementById("menuBarList");
	
	//elMenuBarList = 
}

/*function generateTopMenu() {
	var menuHTML = '<nav><ul>';
	var i;
	var currPage = getCurrPage();
	
	for (i=0; i<sectionNames.length; i++) {
		menuHTML += '<li ';
		if (currPage == sectionNames[i].title) {
			menuHTML += 'class="activePage"';
		}
		menuHTML += '><a href="' + sectionNames[i].href + '"><p>' + sectionNames[i].title + '</p></a></li>';
	}
	
	for (i=0; i<extraButtons.length; i++) {
		menuHTML += '<li class="rightSide">';
		menuHTML += '<a';
		if (extraButtons[i].href != null) {
			menuHTML += ' href="' + extraButtons[i].href + '"';
		}
		if (extraButtons[i].onclick != null) {
			menuHTML += ' onclick="' + extraButtons[i].onclick + '"';
		}
		menuHTML += '><p>' + extraButtons[i].title + '</p></a></li>';
	}
	menuHTML += '</ul></nav>'
	document.write(menuHTML);
}*/

function userIsLoggedIn() {
	return true;
}

function getCurrPage() {
	var regexp = /^\/?(\w*)/;
	var pageName = regexp.exec(window.location.pathname)[1];
	if (pageName == "index") return "Home";
	pageName = pageName.charAt(0).toUpperCase() + pageName.slice(1);
	return pageName;
}
