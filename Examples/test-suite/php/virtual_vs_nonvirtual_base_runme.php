<?php

require "tests.php";

$fail = new SimpleClassFail();
$work = new SimpleClassWork();

check::equal($work->getInner()->get(), $fail->getInner()->get(), "should both be 10");

check::done();
