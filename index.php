<?php

ini_set('display_errors','Off');
date_default_timezone_set('Europe/Moscow');

$text = htmlspecialchars($_GET["text"]);

if (!empty($text))
{
	file_put_contents("chat.txt", $text);
	file_put_contents("log.txt", $text, FILE_APPEND);
	echo "LEFTWALL: " . $text . " :RIGHTWALL";
}
else
{
	echo "LEFTWALL: " . file_get_contents("chat.txt"); . " :RIGHTWALL";
}
?>
