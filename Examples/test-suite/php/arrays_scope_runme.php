<?php

require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('arrays_scope','Bar'));
// No new globals
check::globals(array());

$bar=new bar();
$bar->blah($bar->adata, $bar->bdata, $bar->cdata);
// Like C/C++, SWIG treats `int asize[ASIZE]` as `int*` so there's no checking
// of the passed array size.
$bar->blah($bar->bdata, $bar->cdata, $bar->adata);

check::done();
