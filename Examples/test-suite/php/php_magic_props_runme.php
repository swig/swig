<?php

require "tests.php";

$o = new MagicProps();

// __set inline (int)
$o->iv = 42;
check::equal($o->iv, 42, "int __set/__get");

// __set inline (double)
$o->dv = 3.14;
check::equal($o->dv, 3.14, "double __set/__get");

// __set inline (bool)
$o->bv = true;
check::equal($o->bv, true, "bool __set/__get (true)");
$o->bv = false;
check::equal($o->bv, false, "bool __set/__get (false)");

// Verify that chained accesses work correctly
$o->iv = 100;
$o->dv = 1.5;
check::equal($o->iv, 100, "chained access iv");
check::equal($o->dv, 1.5, "chained access dv");

// Rewrite and re-verify
$o->iv = 200;
check::equal($o->iv, 200, "rewrite iv");

check::done();
