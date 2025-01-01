<?php
	@extract($_GET);
	
	require 'lib/config/appconfig.inc.php';

	//$protocol = stripos($_SERVER['SERVER_PROTOCOL'],'https') === true ? 'https://' : 'http://';

	//$actualURL = "http://kabam.com";
	$actualDescr = empty($description) ? "" : $description;
	$actualLevel = empty($level) ? 0 : $level;
?>
<html>
	<head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# <?= FACEBOOK_APP_NAMESPACE ?>: http://ogp.me/ns/fb/<?= FACEBOOK_APP_NAMESPACE ?>#">
		<meta property="fb:app_id" content="<?= FACEBOOK_APP_ID ?>" />
		<meta property="og:type"   content="<?= FACEBOOK_APP_NAMESPACE ?>:entity" />
		<meta property="og:url"    content="<?= FACEBOOK_APP_PATH ?>/entity.php?title=<?= URLEncode($title) ?>&img=<?= URLEncode($img) ?>&level=<?= URLEncode($level) ?>&description=<?= URLEncode($description) ?>" />
		<meta property="og:title"  content="<?= $title ?>" />
		<meta property="og:description"  content="<?= $actualDescr ?>" />
		<meta property="og:image"  content="<?= $img ?>" />
		<meta property="<?= FACEBOOK_APP_NAMESPACE ?>:level" content="<?= $actualLevel ?>" />
	</head>
	<body>
	</body>
</html>
