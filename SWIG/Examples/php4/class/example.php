<?php

global $EXAMPLE_LOADED__;
if ($EXAMPLE_LOADED__) return;
$EXAMPLE_LOADED__ = true;

/* if our extension has not been loaded, do what we can */
if (!extension_loaded("example")) {
	if (!dl("libexample.so")) return;
}



?>
