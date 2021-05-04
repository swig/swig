<?php

require "tests.php";

check::classes(array('Foo','Spam'));
$spam=new Spam();

check::equal(0,$spam->blah(),"spam object method");

check::done();
