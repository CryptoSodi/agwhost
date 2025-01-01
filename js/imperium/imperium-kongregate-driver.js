function ImperiumKongregateDriverClass() {
	var KONGREGATE_SCRIPT_ID = "kongregateScript";
	var PRE_GAME_DIV_ID = "preGameDiv";
	var FLASH_GRP_DIV_ID = "flashGrp";
	var KONGREGATE_LOGIN_ANCHOR_ID = "kongregateLoginAnchor";

	//--------------------------------------------------------------------------

	var KongregateApi = null;

	var OnStartupComplete = null;

	//--------------------------------------------------------------------------

	function setupLogin() {
		var preGameDiv = document.getElementById( PRE_GAME_DIV_ID );
		var flashGrpDiv = document.getElementById( FLASH_GRP_DIV_ID );
		if ( KongregateApi.services.isGuest() ) {
			var loginAnchor = document.getElementById( KONGREGATE_LOGIN_ANCHOR_ID );
			if ( !loginAnchor ) {
				loginAnchor = document.createElement( "a" );
				loginAnchor.id = KONGREGATE_LOGIN_ANCHOR_ID;
				loginAnchor.href = "javascript:ImperiumKongregateDriver.openKongregateRegistrationWindow();";
				loginAnchor.title = "Please log into Kongregate to play.";

				var loginImage = document.createElement( "img" );
				loginImage.src = "img/kongregate-splash-guest.png";
				loginImage.alt = loginAnchor.title;
				loginAnchor.appendChild( loginImage );

				preGameDiv.appendChild( loginAnchor );
			}

			flashGrpDiv.style.display = "none";
			preGameDiv.style.display = "block";
		} else {
			preGameDiv.style.display = "none";
			flashGrpDiv.style.display = "block";

			if ( OnStartupComplete ) {
				OnStartupComplete();
				OnStartupComplete = null;
			}
		}
	}

	function onKongregateApiLoaded() {
		KongregateApi.services.addEventListener( "login", setupLogin );
		setupLogin();
	}

	function onKongregateScriptLoaded() {
		if ( KongregateApi ) {
			onKongregateApiLoaded();
		} else {
			kongregateAPI.loadAPI(
				function() {
					KongregateApi = kongregateAPI.getAPI();
					onKongregateApiLoaded();
				} );
		}
	}

	//--------------------------------------------------------------------------

	this.startup = function( onStartupComplete ) {
		document.body.style[ "background-color" ] = "#333";

		OnStartupComplete = onStartupComplete;

		// Load the Kongregate script.
		var kongregateScript = document.getElementById( KONGREGATE_SCRIPT_ID );
		if ( kongregateScript ) {
			onKongregateScriptLoaded();
		} else {
			kongregateScript = document.createElement( "script" );
			kongregateScript.id = KONGREGATE_SCRIPT_ID;
			kongregateScript.src = "//www.kongregate.com/javascripts/kongregate_api.js";
			kongregateScript.onload =
				function() {
					if ( !kongregateScript.readyState || kongregateScript.readyState === "loaded" || kongregateScript.readyState === "complete" ) {
						kongregateScript.onreadystatechange = null;
						kongregateScript.onload = null;
						onKongregateScriptLoaded();
					}
				};
			kongregateScript.onreadystatechange = kongregateScript.onload;
			var scriptElements = document.getElementsByTagName( "script" );
			scriptElements[ 0 ].parentNode.insertBefore( kongregateScript, scriptElements[ scriptElements.length - 1 ] );
		}
	};

	this.openKongregateRegistrationWindow = function() {
		if ( KongregateApi ) {
			KongregateApi.services.showRegistrationBox();
		}
	};

	this.openKongregateKredPurchaseDialog = function( purchaseMethod ) {
		if ( KongregateApi ) {
			KongregateApi.mtx.showKredPurchaseDialog( purchaseMethod );
		}
	};

	this.submitKongregateStat = function( name, value ) {
		if ( KongregateApi ) {
			KongregateApi.stats.submit(name, value);
		}
	};

	this.purchaseKongregateItems = function( items ) {
		if ( KongregateApi ) {
			KongregateApi.mtx.purchaseItems(
				items,
				function() {
					var swf = Imperium.getSwf();
					if ( swf ) {
						swf.onKongregateItemsPurchased( items );
					}
				} );
		}
	};

	this.getPlayerKongregateUserId = function() {
		if ( KongregateApi ) {
			return KongregateApi.services.getUserId();
		} else {
			return null;
		}
	};

	this.getPlayerKongregateUsername = function() {
		if ( KongregateApi ) {
			return KongregateApi.services.getUsername();
		} else {
			return null;
		}
	};

	this.getPlayerKongregateGameAuthToken = function() {
		if ( KongregateApi ) {
			return KongregateApi.services.getGameAuthToken();
		} else {
			return null;
		}
	};
}

ImperiumKongregateDriver = new ImperiumKongregateDriverClass();

_mq_imperiumkongregatedriver = _mq_imperiumkongregatedriver || [];
while ( _mq_imperiumkongregatedriver.length > 0 ) {
	var params = _mq_imperiumkongregatedriver.shift();
	var method = params.shift();
	ImperiumKongregateDriver[ method ].apply( ImperiumKongregateDriver, params );
}

_mq_imperiumkongregatedriver.push = function( params ) {
	var method = params.shift();
	ImperiumKongregateDriver[ method ].apply( ImperiumKongregateDriver, params );
};
