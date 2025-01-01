<?php
	// TODO: This file should be changed to html/js.
	require_once( "lib/config/paymentsconfig.inc.php" );
	require_once( "platform/facebook/lib/config/appconfig.inc.php" );
?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
	<head>
		<title>Imperium: Galactic War</title>
		<meta name="google" value="notranslate" />
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	</head>
	<body onload="Imperium.init( '<?= PIXEL_URI ?>' );">
		<link rel="Stylesheet" href="css/game-canvas.css" />
		<link rel="Stylesheet" href="css/facebook-app.css" />
		<link rel="Stylesheet" href="css/paywall-KBPAY.css" />

		<img src="https://<?= PIXEL_URI ?>/pixels/indexLoaded" style="display:none;" />

		<div id="fbMenu">
			<ul id="fbBtnBar">
				<li class="first"><a id="nav_play" onclick="" href="#" class="selected">Play</a></li>
				<li><a id="nav_invite_friends" href="#" onclick="window.Imperium.sharePlayRequest_js2as3();">Invite Friends</a></li>
				<li><a id="nav_buy" href="#" onclick="window.Imperium.popPaywall( window.Imperium.getKabamNaid(), window.Imperium.getPlayerOAuthToken() );">Buy Palladium</a></li>
				<li><a id="nav_fan_page" href="#" onclick="window.open('https://www.facebook.com/Imperium', '_blank');">Fan Page</a></li>
				<li><a id="nav_support" onclick="window.open('http://kabam.force.com/PKB?game=Imperium_Galactic_War&language=' + window.Imperium.getLanguage(), '_blank');" href="#">Help</a></li>
				<li class="last"><a id="nav_discuss" onclick="window.open('http://community.kabam.com/forums/forumdisplay.php?896-Imperium-Galactic-War', '_blank');" href="#">Discuss</a></li>
				<li><iframe id="nav_like" src="" scrolling="no" frameborder="0" allowTransparency="true"></iframe></li>
			</ul>
		</div>

		<div id="preGameDiv">
		</div>

		<div id="flashGrp">
			<div id="flashContent">
				<p>Adobe Flash Player 11.5.0 or later is required to run this application.</p>
				<a href='http://www.adobe.com/go/getflashplayer' target="_blank"><img src='img/get-flash-player.jpg' alt='Get Adobe Flash player' /></a>
			</div>
			<div id="swfNotLoaded">
				<p>The application could not be loaded due to network restrictions or technical issues.</p>
			</div>
			<noscript>
				<p>JavaScript must be enabled in order to run this application.</p>
				<img src="https://<?= PIXEL_URI ?>/pixels/scriptDisabled" style="display:none;" />
			</noscript>
		</div>

		<script src="js/swfobject/swfobject.min.js"></script>
		<script src="js/jquery/jquery-1.7.1.min.js"></script>
		<script src="<?= KABAMPAYMENTSERVER_URI ?>/js/KBPAY_api.js"></script>
		<script src="js/ua-parser-js/ua-parser.min.js"></script>
		<script src="js/config/commonConfig.js"></script>
		<script src="js/config/platformConfig.js"></script>
		<script src="js/imperium/config/imperium-config.js"></script>
		<script src="js/imperium/imperium.js"></script>
	</body>
</html>