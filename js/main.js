function DoOnLoad()
{		
	console.log("IGW-Client-Version: " + CLIENT_VERSION);
	console.log("IGW-Version: " + GAME_VERSION);
	initLanguageSelector();
	SaveMainUrl();	

	
}
function SaveMainUrl()
{
	sessionStorage.setItem("mainUrl", document.location.href);
}

function eraseCache(){
	var ref = window.location.href;
	if( ref.indexOf("?") == -1)
       		window.location.href = window.location.href+'?eraseCache=true';
	else
		window.location.href = window.location.href+'&eraseCache=true';
}


function setCookie(cname, cvalue, exdays) {
	
	if(exdays>0)
	{
		var d = new Date();
		d.setTime(d.getTime() + (exdays*24*60*60*1000));
		var expires = "expires="+ d.toUTCString();
		document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
	}
	else
	{
		document.cookie = cname + "=" + cvalue + ";";
	}
}

function getCookie(cname) {
  var name = cname + "=";
  var decodedCookie = decodeURIComponent(document.cookie);
  var ca = decodedCookie.split(';');
  for(var i = 0; i <ca.length; i++) {
	var c = ca[i];
	while (c.charAt(0) == ' ') {
	  c = c.substring(1);
	}
	if (c.indexOf(name) == 0) {
	  return c.substring(name.length, c.length);
	}
  }
  return "";
}