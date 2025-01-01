<?php
	require_once( "lib/config/authconfig.inc.php" );

	if ( ALLOW_FAKELOGIN )
	{
		// Redirect to dev login interface on the AuthorizationServer.
		header( "Location: " . AUTHSERVER_URI . "/login/dev/web" );
	}
	else
	{
		// Return "file not found."
		http_response_code( 404 );
	}
?>