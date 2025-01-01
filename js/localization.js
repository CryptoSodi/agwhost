var LOCALIZATION_OPTIONS = {
	"en" : "English",
	"de" : "Deutsch",
	"fr" : "Français",
	"it" : "Italiano",
	"es" : "espanol"
}

function initLanguageSelector() {
	
	var x = document.getElementById("language-selector");
	if(x!== null)
	{
		for (const property in LOCALIZATION_OPTIONS) {
			var c = document.createElement("option");
			c.value = property;
			c.text = LOCALIZATION_OPTIONS[property];
			x.options.add(c, 1);
			console.log(property + " " + LOCALIZATION_OPTIONS[property]);
		}
		
		var lang = getLocalization();
		console.log("Saved language: " + lang);
		for (i = 0; i < x.length; i++) {
			if(lang == x.options[i].value) {
				x.value = lang;
				return;
			}
		}
		x.value = "en";
	}
};
function onLanguageChange()
{
	var x = document.getElementById("language-selector");
	console.log("Language changed to " + x.value);
	setLocalization(x.value);
};
function setLocalization(tag) {
	
	for (const property in LOCALIZATION_OPTIONS) {
		if(tag == property) {
			setCookie("GameLanguage", tag);
			return;
		}
			
	}
	
	setCookie("GameLanguage", "en");
};

function getLocalization() {
	var lang = getCookie("GameLanguage");
	if(lang.length==0)
		return "en";
	
	for (const property in LOCALIZATION_OPTIONS) {
		if(lang == property) {
			return lang;
		}
	}
		
	return "en";
};