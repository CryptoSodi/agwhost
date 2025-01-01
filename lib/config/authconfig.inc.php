<?php
	define( "LOGIN_PROTOCOL", "http" );
	define( "LOGIN_HOST", $_SERVER[ "SERVER_NAME" ] );
	define( "LOGIN_PORT", 4000 );

	define( "AUTHSERVER_URI", "http://" . $_SERVER[ "SERVER_ADDR" ] . ":4000" );
	define( "ALLOW_FAKELOGIN", true );

	define( "KABAM_API_APP_ID", 1166 );
	define( "KABAM_API_APP_SECRET", "79aea124fcf56d1902a73ef562daded4" );
	define( "KABAM_API_URI", "https://api-sandbox.kabam.com" );
	define( "KABAM_API_ENV", "SANDBOX" );
?>
