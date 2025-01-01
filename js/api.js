function getIGWQueryParameter(value) {
		var match,
			pl     = /\+/g,  // Regex for replacing addition symbol with a space
			search = /([^&=]+)=?([^&]*)/g,
			decode = function (s) { return decodeURIComponent(s.replace(pl, " ")); },
			query  = window.location.search.substring(1);

		var urlParams = {};
		while (match = search.exec(query))
			urlParams[decode(match[1])] = decode(match[2]);
		
		return urlParams[value];

	}

function setIGWCookie(cname, cvalue, exdays) {
	
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

function getIGWCookie(cname) {
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

function IGWClass() {
	this.RegisterEntryTagHTTP = function(param){

		var value = getIGWQueryParameter(param);
		if(typeof value === 'undefined' || value === null)
		{
			console.log("Registering entry tag - cannot find url param: " + param);
			return;
		}

		var currentEntryTag = getIGWCookie("IGWEntryTaged");
		if(currentEntryTag.length==0) {
			console.log("Registering: " + value);
			var url = "http://139.59.150.135:4000/entryregister?value=" + value;
			// $.get(url,function(response){
				// console.log(response);
				// });
			var xhr = new XMLHttpRequest();
			xhr.open('GET', url);
			xhr.onload = function() {
				if (xhr.status === 200) {
					console.log(xhr.responseText);
					//if(xhr.responseText == "EntryTag registered")
					setIGWCookie("IGWEntryTaged", "OK");
				}
				else {
					console.log('Request failed.  Returned status of ' + xhr.status);
				}
			};
			xhr.send();
		}
	}
	this.RegisterEntryTagHTTPS = function(param){

		var value = getIGWQueryParameter(param);
		if(typeof value === 'undefined' || value === null)
		{
			console.log("Registering entry tag - cannot find url param: " + param);
			return;
		}
		var currentEntryTag = getIGWCookie("IGWEntryTaged");
		if(currentEntryTag.length==0) {
			console.log("Registering: " + value);
			var url = "https://game.playimperium.com/php/entryRegister.php?value=" + value;
			// $.get(url,function(response){
			//	 console.log(response);
			//	 });
			var xhr = new XMLHttpRequest();
			xhr.open('GET', url);
			xhr.onload = function() {
				if (xhr.status === 200) {
					console.log(xhr.responseText);
					//if(xhr.responseText == "EntryTag registered")
					setIGWCookie("IGWEntryTaged", "OK");
				}
				else {
					console.log('Request failed.  Returned status of ' + xhr.status);
				}
			};
			xhr.send();
		}
	}
}
IGW = new IGWClass();