<?php

	@extract($_GET);
	
	require 'lib/config/appconfig.inc.php';

	$avatarURL = $img;
	$overlayURL = FACEBOOK_APP_PATH . "/defeatedFill.png"; 

	$avatarImage = imagecreatefromgif($avatarURL);
	$overlayImage = imagecreatefrompng($overlayURL);

	$cIndex = imagecolorexact($overlayImage, 255, 255, 255);
	imagecolorset($overlayImage, $cIndex, 255, 0, 0);

	$resizedImage = imagecreatetruecolor(imagesx($avatarImage), imagesy($avatarImage));
	// imagecopyresampled($resizedImage, $overlayImage, 0, 0, 0, 0, imagesx($avatarImage), imagesy($avatarImage), imagesx($overlayImage), imagesy($overlayImage));
	imagecopyresized($resizedImage, $overlayImage, 0, 0, 0, 0, imagesx($avatarImage), imagesy($avatarImage), imagesx($overlayImage), imagesy($overlayImage));
	imagecolortransparent($resizedImage, imagecolorat($resizedImage, 0, 0));
	imagecopymerge($avatarImage, $resizedImage, 0, 0, 0, 0, imagesx($avatarImage), imagesy($avatarImage), 100);

	Header("Content-type: image/jpg");

	imagejpeg($avatarImage, null, 100);
	// imagepng($overlayImage);
	imagedestroy($bkgrdImage);

?>
