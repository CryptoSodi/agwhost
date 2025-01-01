<?php
	require_once( "../lib/config/appconfig.inc.php" );
?>
<html>
	<head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# <?= FACEBOOK_APP_NAMESPACE ?>: http://ogp.me/ns/fb/<?= FACEBOOK_APP_NAMESPACE ?>#">
		<meta property="fb:app_id" content="<?= FACEBOOK_APP_ID ?>" />
		<meta property="og:type" content="game.achievement" />
		<meta property="og:url" content="<?= FACEBOOK_APP_PATH ?>/achievements/EnemyMine_2.php" />
		<meta property="og:title" content="Enemy Mine 2" />
		<meta property="og:description" content="Defeat 500 Enemy NPC Fleets" />
		<meta property="og:image" content="<?= FACEBOOK_APP_PATH ?>/achievements/EnemyMine_2.png" />
		<meta property="game:points" content="25" />
	</head>
	<body>
	</body>
</html>