<?php

require "tests.php4";
require "abstract_inherit.php";

check::classes("Spam");
$spam=new Spam();

check::equal(0,$spam->blah(),"spam object method");
check::equal(0,Spam::blah($spam),"spam class method");

check::done();
?>
