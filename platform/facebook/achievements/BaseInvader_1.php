<?php
	require_once( "../lib/config/appconfig.inc.php" );
?>
<html>
	<head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# <?= FACEBOOK_APP_NAMESPACE ?>: http://ogp.me/ns/fb/<?= FACEBOOK_APP_NAMESPACE ?>#">
		<meta property="fb:app_id" content="<?= FACEBOOK_APP_ID ?>" />
		<meta property="og:type" content="game.achievement" />
		<meta property="og:url" content="<?= FACEBOOK_APP_PATH ?>/achievements/BaseInvader_1.php" />
		<meta property="og:title" content="Base Invader 1" />
		<meta property="og:description" content="Win 10 Base Attacks" />
		<meta property="og:image" content="<?= FACEBOOK_APP_PATH ?>/achievements/BaseInvader_1.png" />
		<meta property="game:points" content="10" />
	</head>
	<body>
	</body>
</html>