<?php

require "tests.php";

check::functions(array('new_pchar', 'delete_pchar', 'pchar_getitem', 'pchar_setitem'));

check::classes(array('Test', 'char_binary'));

$t = new Test();
$str = 'hile';
check::equal(4, $t->strlen($str), "bad multi-arg typemap");
check::equal(4, $t->ustrlen($str), "bad multi-arg typemap");
check::equal(4, $t->strlen("hil\000"), "bad multi-arg typemap");
check::equal(4, $t->ustrlen("hil\000"), "bad multi-arg typemap");

// creating a raw char*
$pc = new_pchar(5);
pchar_setitem($pc, 0, 'h');
pchar_setitem($pc, 1, 'o');
pchar_setitem($pc, 2, 'l');
pchar_setitem($pc, 3, 'a');
pchar_setitem($pc, 4, 0);
delete_pchar($pc);

check::done();
