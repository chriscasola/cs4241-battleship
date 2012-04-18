
/*
 * Menu items and their links
 */
var sectionNames = [
	{title: "Home", href: "/index.html"},
	{title: "About", href: "/about.html"},
	{title: "Leaderboard", href: "/leaderboard.html"},
	{title: "My Battles", href: "/mybattles.html"},
];

var extraButtons = [
	{title: "Login", href: null, onclick: "showLoginOverlay()"},
	{title: "Register", href: "/index.html", onclick: null},
];

function generateTopMenu() {
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
}

function getCurrPage() {
	var regexp = /^\/?(\w*)/;
	var pageName = regexp.exec(window.location.pathname)[1];
	if (pageName == "index") return "Home";
	pageName = pageName.charAt(0).toUpperCase() + pageName.slice(1);
	return pageName;
}
