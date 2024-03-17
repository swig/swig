<?php

require "tests.php";

$c = new C();
$d = new D();
$d->DoSomething($c);

check::done();
