function ImperiumImplClass() {
	this.getQueryParameters = function() {
		var match,
			pl     = /\+/g,  // Regex for replacing addition symbol with a space
			search = /([^&=]+)=?([^&]*)/g,
			decode = function (s) { return decodeURIComponent(s.replace(pl, " ")); },
			query  = window.location.search.substring(1);

		var urlParams = {};
		while (match = search.exec(query))
			urlParams[decode(match[1])] = decode(match[2]);
		return urlParams;
	}

	//--------------------------------------------------------------------------

	this.QUERY_PARAMETERS = this.getQueryParameters();
	this.KABAM_NAID = this.QUERY_PARAMETERS[ "kabam-naid" ];
	this.PLAYER_OAUTH_TOKEN = this.QUERY_PARAMETERS[ "oauthToken" ];
	this.LANGUAGE = this.QUERY_PARAMETERS[ "language" ];

	//--------------------------------------------------------------------------

	this.PlayPlatform = this.QUERY_PARAMETERS[ "play-platform" ];
	this.EntryTag = this.QUERY_PARAMETERS[ "login-bonus" ];
	this.XsollaToken = this.QUERY_PARAMETERS[ "token" ];
	//this.XsollaTokenDragonLauncher = this.QUERY_PARAMETERS[ "xsolla-login-token" ];
	this.XsollaIsNew = this.QUERY_PARAMETERS[ "is_new" ];
	this.AllInGames = false;

	this.Swf = null;
	this.SwfLoaded = false;

	this.PixelUri = "";
	this.FlashVersion = "";

	this.MainUrl = "";
}

//------------------------------------------------------------------------------

function ImperiumClass() {
	
	function getUrlVars() {
		var vars = {};
		var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
			vars[key] = value;
		});
		return vars;
		
		// get query string from url (optional) or window
		var queryString = window.location.search.slice(1);

		// we'll store the parameters here
		var obj = {};

		// if query string exists
		if (queryString) {

			// stuff after # is not part of query string, so get rid of it
			queryString = queryString.split('#')[0];

			var parts = queryString.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
			obj[key] = value;
			});
		}
		return obj;
			// // split our query string into its component parts
			// var arr = queryString.split('&');

			// for (var i = 0; i < arr.length; i++) {
				// // separate the keys and the values
				// var a = arr[i].split('=');

				// // set parameter name and value (use 'true' if empty)
				// var paramName = a[0];
				// var paramValue = typeof (a[1]) === 'undefined' ? true : a[1];
// ;
				// // if the paramName ends with square brackets, e.g. colors[] or colors[2]
				// if (paramName.match(/\[(\d+)?\]$/)) {

					// // create key if it doesn't exist
					// var key = paramName.replace(/\[(\d+)?\]/, '');
					// if (!obj[key]) obj[key] = [];

					// // if it's an indexed array e.g. colors[2]
					// if (paramName.match(/\[\d+\]$/)) {
						// // get the index value and add the entry at the appropriate position
						// var index = /\[(\d+)\]/.exec(paramName)[1];
						// obj[key][index] = paramValue;
					// } else {
						// // otherwise add the value to the end of the array
						// obj[key].push(paramValue);
					// }
				// } else {
					// // we're dealing with a string
					// if (!obj[paramName]) {
						// // if it doesn't exist, create property
						// obj[paramName] = paramValue;
					// } else if (obj[paramName] && typeof obj[paramName] === 'string'){
						// // if property does exist and it's a string, convert it to an array
						// obj[paramName] = [obj[paramName]];
						// obj[paramName].push(paramValue);
					// } else {
					// // otherwise add the property
						// obj[paramName].push(paramValue);
					// }
				// }
			// }
		// }

		// return obj;
	}
	function getUrlParam(parameter, defaultvalue){
		var urlparameter = defaultvalue;
		if(window.location.href.indexOf(parameter) > -1){
			urlparameter = getUrlVars()[parameter];
			}
		return urlparameter;
	}
	
	var ImperiumImpl = new ImperiumImplClass();
	
	var AuthToken = null;
	
	this.getPlayerXsollaGameAuthToken = function() {
		return AuthToken;
	};

	//--------------------------------------------------------------------------

	function loadSwf() {
		var params = {};
		params[ "quality" ] = "high";
		params[ "bgcolor" ] = "#000000";
		params[ "wmode" ] = "direct";
		params[ "allowscriptaccess" ] = "always";
		params[ "allowFullScreenInteractive" ] = "true";
		params[ "flashvars" ] = window.location.search.substr( 1 );

		var attributes = {};
		attributes[ "id" ] = "Imperium";
		attributes[ "name" ] = "Imperium";
		attributes[ "align" ] = "middle";

		swfobject.embedSWF( SWF_URI, "flashContent", "100%", "100%", "11.5.0", "playerProductInstall.swf", false, params, attributes,
			function( e ) {
				if ( e.success ) {
					ImperiumImpl.Swf = e.ref;
				}
				else {
					//ImperiumImpl.Swf = null;
					//ImperiumImpl.SwfLoaded = false;
					ImperiumImpl.FlashVersion = e.version.join( "_" );
					document.getElementById( "flashContent" ).style.display = "block";
					this.popPixel( 3 );
					console.log("SWF was was not embed!");
				}
			} );

		swfobject.createCSS( "#flashContent", "display: block; text-align: center;" );
	}

	//--------------------------------------------------------------------------

	// Initializes the Imperium client.
	this.init = function( pixelUri, allInGames = false ) {
		
		if(allInGames)
		{
			console.log("AllInGames Initialization");
			ImperiumImpl.AllInGames = true;
			
			if(ImperiumImpl.XsollaIsNew == 1)
			{
				console.log("AllInGames user registration");
				var decoded = jwt_decode(ImperiumImpl.XsollaToken);
				if ( decoded.hasOwnProperty('sub'))
				{
					
					$.post('php/allInGameTracking.php',{ 
						userId : decoded.sub
						},function(response){
							console.log("AIG Tracking: " + response);
					});
				}
				else
					console.log("AIG Tracking: invalid token");	
			}
		}
		/*if (ImperiumImpl.PlayPlatform != PLATFORM_IDS[ "kongregate" ])
		{
			var version = getCookie("GameVersion");
			if(version.length==0 || version.localeCompare(GAME_VERSION) != 0)
			{
				console.log("New data - refreshing");
				setCookie("GameVersion",GAME_VERSION);
				location.reload(true);
				//eraseCache();
				console.log("Refreshing in progress...");
				return;
			}
		}*/
		
		this.getCountryCode();
		ImperiumImpl.PixelUri = pixelUri;

		var flashContainer = document.getElementById( "flashGrp" );

		if ( ImperiumImpl.PlayPlatform != PLATFORM_IDS[ "kabam" ] ) {	// TODO: Shouldn't this be safe on all platforms?
			// Disable mouse scroll-wheel events.
			if ( flashContainer.addEventListener ) {
				flashContainer.addEventListener( "mousewheel", this.onMouseWheel, false ); // non-Firefox
				flashContainer.addEventListener( "DOMMouseScroll", this.onMouseWheel, false ); // Firefox
			}
		}
		MainUrl = sessionStorage.getItem("mainUrl");

		if ( ImperiumImpl.PlayPlatform == PLATFORM_IDS[ "xsolla" ] ) {
			console.log("Init Xsolla driver");
			
			//AuthToken = getUrlParam("xsolla-login-token","null").split('#')[0];
			//if(AuthToken == null)
			if( typeof window.launcherParams != "undefined" && typeof window.launcherParams.jwt_token != "undefined")
				AuthToken  = window.launcherParams.jwt_token;
			else
				AuthToken = getUrlParam("token","null").split('#')[0];
			
			console.log("Xsolla driver initilized");
			loadSwf();
			window.history.replaceState({}, document.title, "/");
		}
		else if ( ImperiumImpl.PlayPlatform == PLATFORM_IDS[ "facebook" ] ) {
			// Startup the Imperium Facebook Driver.
			console.log("Init Facebook driver");
			window._mq_imperiumfacebookdriver = window._mq_imperiumfacebookdriver || [];
			window._mq_imperiumfacebookdriver.push( [ "startup", loadSwf ] );
			var imperiumFacebookDriverScript = document.createElement( "script" );
			imperiumFacebookDriverScript[ "src" ] = "js/imperium/imperium-facebook-driver.js";
			var firstScriptElement = document.getElementsByTagName( "script" )[ 0 ];
			firstScriptElement.parentNode.insertBefore( imperiumFacebookDriverScript, null );
		} else if ( ImperiumImpl.PlayPlatform == PLATFORM_IDS[ "kongregate" ] ) {
			
			console.log("Kongregate driver initilized");
			window._mq_imperiumkongregatedriver = window._mq_imperiumkongregatedriver || [];
			window._mq_imperiumkongregatedriver.push( [ "startup", loadSwf ] );
			var imperiumKongregateDriverScript = document.createElement( "script" );
			imperiumKongregateDriverScript.src = "js/imperium/imperium-kongregate-driver.js";
			var firstScriptElement = document.getElementsByTagName( "script" )[ 0 ];
			firstScriptElement.parentNode.insertBefore( imperiumKongregateDriverScript, null );
		} else {
			this.PlayPlatform = 53;
			console.log("Init Xsolla driver");
			
			//AuthToken = XsollaTokenDragonLauncher;
			//if(XsollaTokenDragonLauncher == null)			
			//AuthToken = getUrlParam("xsolla-login-token","null").split('#')[0];
			if( typeof window.launcherParams != "undefined" && typeof window.launcherParams.jwt_token != "undefined")
				AuthToken  = window.launcherParams.jwt_token;
			else
				AuthToken = getUrlParam("token","null").split('#')[0];
			
			console.log("Xsolla driver initilized");
			loadSwf();
			window.history.replaceState({}, document.title, "/");
		}
	};

	this.openXsollaStore = function( accessToken ) {
		
		var url = "https://secure.xsolla.com/paystation2/?access_token=" + accessToken;
		window.open(url, "IGW Xsolla Payment", "height=800,width=600");
		return 1;
	};
	// Opens the paywall iframe.
	this.popPaywall = function( userID, accessToken, language ) {
		
		console.log("Open Paywall\n");
		console.log("UserID: " + userID + "\nAccessToken: " + accessToken);
		// Format the paywall-skin.css uri.
		// var cssPath = window.location.protocol + "//" + window.location.host;
		// var pathnameSlashIndex = window.location.pathname.lastIndexOf( "/" );
		// if ( pathnameSlashIndex != -1 )
			// cssPath += window.location.pathname.substr( 0, pathnameSlashIndex );
		// cssPath += "/css/paywall-skin.css";

		// // Initialize the paywall
		// var initParams = {
			// "paymentServer" : PAYMENTSERVER_URI,
			// "platform" : PLATFORM_NAMES[ ImperiumImpl.PlayPlatform ],
			// "gameid" : KABAM_API_APP_ID,
			// "serverid" : "1",
			// "userid" : userID,
			// "accessToken" : accessToken,
			// "lang" : language,
			// "css" : cssPath
		// };
		// if ( ImperiumImpl.PlayPlatform == PLATFORM_IDS[ "facebook" ] ) {
			// initParams[ "fbappid" ] = FACEBOOK_APP_ID;
			// initParams[ "fbuid" ] = ImperiumFacebookDriver.getPlayerFacebookUserId();
			// initParams[ "fbtpId" ] = ImperiumFacebookDriver.getPlayerFacebookThirdPartyId();
		// }
		// KBPAY.init( initParams );

		// // On some platforms, the Flash client renders above the paywall,
		// // so we have to hide it.
		// var uaParser = new UAParser( window.navigator.userAgent );
		// var ua = uaParser.getResult();
		// var hideFlashClient = ( ua.browser.name == "Firefox" && ua.os.name == "Windows" );
		// if ( hideFlashClient ) {
			// var flashContent = document.getElementById( "flashGrp" );
			// flashContent.style.visibility = "hidden";
		// }

		// // Display the paywall.
		// var showParams = {
			// "iframeOnly" : true,
			// "width" : 740,
			// "height" : 660,
			// "onPaymentWallClose" : function() {
				// // Unhide the Flash client if it was hidden earlier.
				// if ( hideFlashClient ) {
					// var flashContent = document.getElementById( "flashGrp" );
					// flashContent.style.visibility = "visible";
				// }
			// }
		// };
		// KBPAY.showPaymentWall( showParams );
	};

	// Loads user tracking uri's.
//	this.popPixel = function( pixelId ) {
//		// Determine the pixel uri.
//		var uri;
//		switch ( pixelId ) {
//			case 1:
//				uri = "//kabam1-a.akamaihd.net/pixelkabam/html/pixels/impp1.html";
//				break;
//			case 2:
//				uri = "//kabam1-a.akamaihd.net/pixelkabam/html/pixels/impp2.html";
//				break;
//			case 3:
//				uri = "//" + ImperiumImpl.PixelUri + "/pixels/noflash_" + ImperiumImpl.KABAM_NAID + "_v_" + ImperiumImpl.FlashVersion;
//				break;
//			default:
//				return;
//		}
//
//		// Create an iframe to load the pixel.
//		var i = document.createElement( "iframe" );
//		i.style.display = "none";
//		i.onload = function() {
//			i.parentNode.removeChild( i );
//		};
//		i.src = uri + '?cacheavoidance=' + ( new Date() ).getTime();
//		document.body.appendChild( i );
//	};
			
	// Scrollwheel event handler.
	this.onMouseWheel = function( event ) {
		// Don't propagate the event to the browser.
		event.preventDefault();
		event.stopPropagation();			

		// Route mouse wheel events to the game.
		var flashObj = document.getElementById( "Imperium" );
		if ( flashObj ) {
			if ( "wheelDelta" in event )
				var d = event.wheelDelta;
			else
				d = -40 * event.detail;
			flashObj.onMouseWheel_jsCallback( d );
		}				
	};

	// Invites a Facebook friend to play.
	this.sharePlayRequest_js2as3 = function() {
		if ( ImperiumImpl.PlayPlatform != PLATFORM_IDS[ "facebook" ] )
			return;

		var flashObj = document.getElementById( "Imperium" );
		flashObj.sharePlayRequest();
	};

	// Invites a Facebook friend to play.
	this.sharePlayRequest_facebook = function( shareObj ) {
		if ( ImperiumImpl.PlayPlatform != PLATFORM_IDS[ "facebook" ] )
			return;

		ImperiumFacebookDriver.sharePlayRequest( shareObj );
	};

	this.sharePvPVictory_facebook = function( shareObj ) {
		if ( ImperiumImpl.PlayPlatform != PLATFORM_IDS[ "facebook" ] )
			return;

		ImperiumFacebookDriver.sharePvpVictory( shareObj );
	};

	this.shareTransaction_facebook = function( shareObj ) {
		if ( ImperiumImpl.PlayPlatform != PLATFORM_IDS[ "facebook" ] )
			return;

		ImperiumFacebookDriver.shareTransaction( shareObj );
	};

	this.shareLevelUp_facebook = function( shareObj ) {
		if ( ImperiumImpl.PlayPlatform != PLATFORM_IDS[ "facebook" ] )
			return;

		ImperiumFacebookDriver.shareLevelUp( shareObj );
	};
	
	this.getFacebookUserId = function() {
		if ( ImperiumImpl.PlayPlatform != PLATFORM_IDS[ "facebook" ] )
			return "0";
		
		return ImperiumFacebookDriver.getPlayerFacebookUserId();
	};

	this.getFacebookAccessToken = function() {
		if ( ImperiumImpl.PlayPlatform != PLATFORM_IDS[ "facebook" ] )
			return "0";
		
		return ImperiumFacebookDriver.getPlayerFacebookAccessToken();
	};
	
	this.getFacebookItems = function() {
		if ( ImperiumImpl.PlayPlatform != PLATFORM_IDS[ "facebook" ] )
			return "0";
		
		var result = null;
		var xmlhttp = new XMLHttpRequest();
		xmlhttp.open("GET", "./fb/facebook_items.json", false);
		xmlhttp.send();
		if (xmlhttp.status==200) {
			result = xmlhttp.responseText;
		 }
		return result;
	};
	
	this.openFacebookPaywall = function(quantity) {
		if ( ImperiumImpl.PlayPlatform != PLATFORM_IDS[ "facebook" ] )
			return;
		
		ImperiumFacebookDriver.openPaywall(quantity);
	};

	this.getKabamNaid = function() {
		return ImperiumImpl.KABAM_NAID;
	};

	this.getPlayerOAuthToken = function() {
		return ImperiumImpl.PLAYER_OAUTH_TOKEN;
	};

	this.getLanguage = function() {
		return ImperiumImpl.LANGUAGE;
	};

	this.setPlayPlatform = function( playPlatform ) {
		ImperiumImpl.PlayPlatform = playPlatform;
	};

	this.getPlayPlatform = function() {
		return ImperiumImpl.PlayPlatform;
	};
	
	this.getLoginProtocol = function() {
		return ImperiumConfig.LOGIN_PROTOCOL;
	};

	this.getLoginHostname = function() {
		return ImperiumConfig.LOGIN_HOSTNAME;
	};

	this.getLoginPort = function() {
		return ImperiumConfig.LOGIN_PORT;
	};
	
	this.getPaymentProtocol = function() {
		return ImperiumConfig.PAYMENT_PROTOCOL;
	};

	this.getPaymentHostname = function() {
		return ImperiumConfig.PAYMENT_HOSTNAME;
	};

	this.getPaymentPort = function() {
		return ImperiumConfig.PAYMENT_PORT;
	};

	this.getSwf = function() {
		return ImperiumImpl.Swf;
	};
	
	this.getLocalizationObject = function() {
		
		var saveAfter = false;
		var lang = getCookie("GameLanguage");
		if(lang.length==0)
		{
			lang = "en";//window.navigator.language;
			saveAfter = true;
		}
		
		var ret = LOCALIZATION_MAP[lang];
		if(typeof ret == "undefined")
		{
			lang = lang.slice(0, 3);
			ret = LOCALIZATION_MAP[lang];
			saveAfter = true;
		}
		if(typeof ret == "undefined")
		{
			lang = lang.slice(0, 2);
			ret = LOCALIZATION_MAP[lang];
			saveAfter = true;
		}
		if(typeof ret == "undefined")
		{
			lang = "en";
			ret = LOCALIZATION_MAP[lang];
			saveAfter = true;
		}
		
		if(saveAfter)
			this.saveLocalizationTag(lang);
		return ret;
	}
	
	this.getLocalizationFolder = function() {
		return this.getLocalizationObject().folder;
	};
	
	this.getLocalizationVOFolder = function() {
		return this.getLocalizationObject().VO;
	};
	
	this.getMainFont = function() {
		return this.getLocalizationObject().mainFont;
	};
	
	this.getTraceFont = function() {
		return this.getLocalizationObject().traceFont;
	};
	
	this.getFont = function(nr) {
		if(nr==0)
			return this.getLocalizationObject().font_0;
		if(nr==1)
			return this.getLocalizationObject().font_1;
		else
			return this.getLocalizationObject().font_0;
	};
	
	this.saveLocalizationTag = function(tag){
		setLocalization(tag);
	};
	
	
	
	this.getLocalizationTag = function(){
		return getLocalization();
	};
	
	
	this.getCountryCode = function(){
		
		var country = getCookie("GameCountry");
		if(country.length==0)
		{
			$.post('php/get_country_code.php',{ },function(response){
				if(country.length<=3)
				{
					console.log("Country Code: " + response);
					setCookie("GameCountry", response);
				}
			});
			
			return "US";
		}
		else
			return country;
	};
	
	this.getEntryTag = function(){
		if(ImperiumImpl.EntryTag!=null && ImperiumImpl.EntryTag.length>0)
			return ImperiumImpl.EntryTag;

		if(ImperiumImpl.AllInGames)
			return "allin";
		else
			return "";
	}
	
	this.getLanguageCode = function(){
		
		var lang = this.getLocalizationTag();
		console.log("Language Code: " + lang);
		return lang;
	};


	this.onSwfLoaded = function() {
		if ( ImperiumImpl.SwfLoaded ) {
			return;
		}

		ImperiumImpl.SwfLoaded = true;

		updateBatteryStatus();
	};

	this.getBattleWebPath = function () {
	    return ImperiumConfig.BATTLE_WEB_PATH;
	};

	
	this.onRefresh = function () {
		console.log("Refresh");
		//window.location.reload(true);
		eraseCache();
	};
	
	this.onLogOut = function () {
		if(MainUrl.length>0)
		{
			console.log("Log Out");
			document.location.href = MainUrl + "?logout=true";
			//FB.logout(function(response) {
  			//// user is now logged out
			//});
		}
		else
		{
			reloadSwf();
		}
	};

	//--------------------------------------------------------------------------
	this.reloadSwf = function()
	{
		ImperiumImpl.SwfLoaded = false;
		ImperiumImpl.Swf = null;
		
		swfobject.removeSWF("Imperium");
		$('#flashGrp').prepend("<div id='flashContent'></div>");
		
		loadSwf();
	};
	
}

Imperium = new ImperiumClass();
