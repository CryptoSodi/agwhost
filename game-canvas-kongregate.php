<?php
	// TODO: This file should be changed to html/js.
	if ( $_SERVER[ "REQUEST_METHOD" ] != "GET" )
	{
		http_response_code( 405 );
		exit();
	}

	require_once( "lib/config/assetconfig.inc.php" );
	require_once( "platform-constants.inc.php" );

	$queryArray = $_GET;
	unset( $queryArray[ "DO_NOT_SHARE_THIS_LINK" ] );	// Remove unneeded variables to make room for additions.
	unset( $queryArray[ "KEEP_THIS_DATA_PRIVATE" ] );
	$queryArray[ "play-platform" ] = PlayPlatform::Kongregate;
	header( "Location: https://" . DEPLOYMENT_HOST . ( ( strlen( DEPLOYMENT_PATH ) > 0 ) ? ( "/" . DEPLOYMENT_PATH ) : "" ) . "/game-canvas.php?" . http_build_query( $queryArray ) );
?>