function ImperiumFacebookDriverClass() {
	var FACEBOOK_SCRIPT_ID = "facebook-jssdk";
	var COMUFY_SCRIPT_ID = "comufy-js";

	//--------------------------------------------------------------------------

	var PlayerFacebookUserId = 0;
	var PlayerFacebookThirdPartyId = "";
	var PlayerFacebookAccessToken = "";

	//--------------------------------------------------------------------------

	this.startup = function( onStartupComplete ) {
		var flashContainer = document.getElementById( "flashGrp" );

		// Show the facebook menu bar.
		//changed document.getElementById( "fbMenu" ).style.display = "block";
		flashContainer.style.marginTop = "30px";

		// Install the "Like" button on the facebook menu bar.
		var likeFrameSrc =
			"//www.facebook.com/plugins/like.php?href=https%3A%2F%2Fapps.facebook.com%2F" +
			FACEBOOK_APP_NAMESPACE + "&send=false&layout=button_count&width=450&" +
			"show_faces=false&font&colorscheme=light&action=like&height=21&appId=" + FACEBOOK_APP_ID;
		//changed document.getElementById( "nav_like" ).src = likeFrameSrc;

		// Define the function to be called when the Facebook SDK finishes loading.
		window.fbAsyncInit = function() {
			var channelPath = window.location.protocol + "//" + window.location.host;
			var pathnameSlashIndex = window.location.pathname.lastIndexOf( "/" );
			if ( pathnameSlashIndex != -1 ) {
				channelPath += window.location.pathname.substr( 0, pathnameSlashIndex );
			}
			channelPath += "/platform/facebook/channel.php";

			FB.init( {
				appId : FACEBOOK_APP_ID, // Facebook app id
				channelUrl : channelPath, // Facebook channel uri
				status : true, // Check login status.
				cookie : true, // Enable cookies to allow the server to access the session.
				xfbml : true, // Parse XFBML.
				oauth : true
			} );

			FB.login( function( response ) {
				// TODO: Handle errors.
				if ( response.error ) {
					console.log('Login Error: ' + response.error);
				} else if (response.authResponse)
				{
					PlayerFacebookAccessToken =  FB.getAuthResponse()['accessToken'];
					//console.log('Access Token: ' + PlayerFacebookAccessToken);
					
					FB.api( "/me", { "fields" : "id,third_party_id" }, function( response ) {
						if ( response ) {
							if ( response.error ) {
								console.log('Api Error: '+ response.error);
								// TODO: Handle errors.
							} else {
								PlayerFacebookUserId = response.id;
								PlayerFacebookThirdPartyId = response.third_party_id;
								//console.log('UserId: '+PlayerFacebookUserId);
								//console.log('ThirdPartyId: '+PlayerFacebookThirdPartyId);
							}
						} else {
							// TODO: Handle null response.
							console.log('Api Error');
						}

						if ( onStartupComplete )
							onStartupComplete();
					} );
					
				}
				else {
					console.log('Login Error');
				}
			} );

			// Load the Comufy SDK.
			// var comufyScript = document.getElementById( COMUFY_SCRIPT_ID );
			// if ( !comufyScript )
			// {
				// comufyScript = document.createElement( "script" );
				// comufyScript.id = COMUFY_SCRIPT_ID;
				// comufyScript.src = "//tracker.comufy.com/tracker.js?domain=kabam&appId=" + FACEBOOK_APP_ID;
				// var facebookScript = document.getElementById( FACEBOOK_SCRIPT_ID );
				// facebookScript.parentNode.insertBefore( comufyScript, facebookScript.nextSibling );
			// }
		};

		// Load the Facebook SDK.
		var facebookScript = document.getElementById( FACEBOOK_SCRIPT_ID );
		if ( !facebookScript )
		{
			facebookScript = document.createElement( "script" );
			facebookScript.id = FACEBOOK_SCRIPT_ID;
			facebookScript.src = "//connect.facebook.net/en_US/all.js#xfbml=1&appId=" + FACEBOOK_APP_ID;
			var scriptElements = document.getElementsByTagName( "script" );
			scriptElements[ 0 ].parentNode.insertBefore( facebookScript, scriptElements[ scriptElements.length - 1 ] );
		}
	};
	
	this.sharePlayRequest = function( shareObj ) {
		var obj = {
		   method : "apprequests",
		   message : shareObj.description,
		   title : shareObj.title
		};
		FB.ui(
			obj,
			function( response ) {
					if ( response ) {
						if ( response.error ) {
							alert( "An error occurred: " + response.error.message );
						}
					} else {
						// Window was closed.
					}
				} );
	};
	
	this.sharePvpVictory = function( shareObj ) {
		var obj = {
			method: 'feed',
			link: 'http://apps.facebook.com/' + FACEBOOK_APP_NAMESPACE,
			picture: shareObj.image,
			name: shareObj.name,
			caption: shareObj.caption,
			description: shareObj.description
		};
		FB.ui( obj, function( response ) {} );
	};
	
	this.shareTransaction = function( shareObj ) {
		var url = FACEBOOK_APP_PATH + "/entity.php?title=" + shareObj.title +
			"&img=" + shareObj.image + 
			"&description=" + shareObj.description;

		var action = "/me/" + FACEBOOK_APP_NAMESPACE + ":" + shareObj.type;
		FB.api( action, "post", { entity: url }, function( response ) {} );
	};

	this.shareLevelUp = function( shareObj ) {
		var url = FACEBOOK_APP_PATH + "/entity.php?title=" + shareObj.title + 
			"&img=" + shareObj.image + 
			"&description=" + shareObj.description + 
			"&level=" + shareObj.level;

		var action = "/me/" + FACEBOOK_APP_NAMESPACE + ":" + shareObj.type;
		FB.api( action, "post", { entity: url }, function( response ) {} );
	};

	this.getPlayerFacebookUserId = function() {
		return PlayerFacebookUserId;
	};

	this.getPlayerFacebookThirdPartyId = function() {
		return PlayerFacebookThirdPartyId;
	};
	
	this.getPlayerFacebookAccessToken = function() {
		return PlayerFacebookAccessToken;
	};
	
	this.openPaywall = function( quantity ) {
		FB.ui({
			  method: 'pay',
			  action: 'purchaseitem',
			  product: 'game.playimperium.com/fb/palladium3.html',
			  quantity: quantity,                 // optional, defaults to 1
			},
			function( response ) {
				if ( response ) {
					if ( response.error ) {
						alert( "An error occurred: " + response.error.message );
					}
				} else {
					console(response);
					var swf = Imperium.getSwf();
					if ( swf ) {
						swf.onFacebookItemsPurchased( response );
					}
				}
			}
		);
	}

	//--------------------------------------------------------------------------

	window._mq_imperiumfacebookdriver = window._mq_imperiumfacebookdriver || [];
	while ( window._mq_imperiumfacebookdriver.length > 0 ) {
		var params = window._mq_imperiumfacebookdriver.shift();
		var method = params.shift();
		this[ method ].apply( this, params );
	}

	window._mq_imperiumfacebookdriver.push = function( params ) {
		var method = params.shift();
		this[ method ].apply( this, params );
	};
}

ImperiumFacebookDriver = new ImperiumFacebookDriverClass();