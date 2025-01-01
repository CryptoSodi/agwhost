<?php
	require_once( "../lib/config/appconfig.inc.php" );
?>
<html>
	<head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# <?= FACEBOOK_APP_NAMESPACE ?>: http://ogp.me/ns/fb/<?= FACEBOOK_APP_NAMESPACE ?>#">
		<meta property="fb:app_id" content="<?= FACEBOOK_APP_ID ?>" />
		<meta property="og:type" content="game.achievement" />
		<meta property="og:url" content="<?= FACEBOOK_APP_PATH ?>/achievements/WarStories_1.php" />
		<meta property="og:title" content="War Stories 1" />
		<meta property="og:description" content="Complete Chapter 1 of Story Missions" />
		<meta property="og:image" content="<?= FACEBOOK_APP_PATH ?>/achievements/WarStories_1.png" />
		<meta property="game:points" content="10" />
	</head>
	<body>
	</body>
</html>