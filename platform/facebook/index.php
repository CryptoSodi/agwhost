<?php
	require_once( "../../lib/config/authconfig.inc.php" );
	require_once( "lib/facebook.php" );
	require_once( "lib/config/appconfig.inc.php" );

	$app_url = 'https://apps.facebook.com/' . FACEBOOK_APP_NAMESPACE . '/';
	$scope = 'email,publish_actions';

	// Init the Facebook SDK
	$facebook = new Facebook(array(
		'appId'  => FACEBOOK_APP_ID,
		'secret' => FACEBOOK_APP_SECRET,
	));

	// Apply to extend access on the current token
	//$facebook->setExtendedAccessToken();

	// Get the current user
	$facebookUserId = $facebook->getUser();

	// Parse the marketing referrer tag.
	// This can be specified as either entrytag, entrypt, or fb_source.
	$referrerTagArray = null;
	if ( isset( $_POST[ "entrytag" ] ) || isset( $_POST[ "entrypt" ] ) || isset( $_POST[ "fb_source" ] ) )
	{
		// The tag is specified in the uri.
		$referrerTagArray = $_POST;
	}
	else
	{
		// The tag isn't specified in the uri.
		// It may be specified in the referer uri.
		if ( isset( $_SERVER[ "HTTP_REFERER" ] ) )
		{
			$httpReferer = $_SERVER[ "HTTP_REFERER" ];
			$httpRefererQuery = parse_url( $httpReferer, PHP_URL_QUERY );
			parse_str( $httpRefererQuery, $referrerTagArray );
		}
		else
		{
			$referrerTagArray = array();
		}
	}

	$referrerTag = "";
	if ( isset( $referrerTagArray[ "entrytag" ] ) )
		$referrerTag = $referrerTagArray[ "entrytag" ];
	else if ( isset( $referrerTagArray[ "entrypt" ] ) )
		$referrerTag = $referrerTagArray[ "entrypt" ];
	else if ( isset( $referrerTagArray[ "fb_source" ] ) )
		$referrerTag = "igw_100-fb_" . $referrerTagArray[ "fb_source" ] . "-z-z-z-z";

	// If the user has not installed the app, redirect them to the login dialog.
	if ( !$facebookUserId ) 
	{
		$loginUrl = $facebook->getLoginUrl(array(
			'scope' => $scope,
			'redirect_uri' => ( $app_url . "?entrytag=" . urlencode( $referrerTag ) )
		));

		// We have to use Javascript rather than a header redirect
		// because we have to break out of the iframe; Facebook
		// disallows loading the login page in an iframe for security.
		echo "<html>\n";
		echo "	<head>\n";
		echo "		<title></title>\n";
		echo "	</head>\n";
		echo "	<body>\n";
		echo "		<script type=\"text/javascript\">\n";
		echo "			top.location.assign(\"" . $loginUrl . "\");\n";
		echo "		</script>\n";
		echo "	</body>\n";
		echo "</html>";
		exit();
	}

	$signedRequest = $facebook->getSignedRequest();
	$postData = http_build_query(
		array(
			"facebook-user-id" => $facebookUserId,
			"facebook-access-token" => $signedRequest[ "oauth_token" ],
			"referrer-tag" => $referrerTag ) );

	$curlHandle = curl_init();
	curl_setopt( $curlHandle, CURLOPT_URL, AUTHSERVER_URI . "/login/facebook" );
	curl_setopt( $curlHandle, CURLOPT_POST, true );
	curl_setopt( $curlHandle, CURLOPT_POSTFIELDS, $postData );
	curl_setopt( $curlHandle, CURLOPT_SSL_VERIFYPEER, false );	// TODO: Don't do this -- it makes MITM attacks possible.
	curl_exec( $curlHandle );
	curl_close( $curlHandle );
?>
