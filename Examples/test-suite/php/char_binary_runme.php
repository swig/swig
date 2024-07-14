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

// FIXME: These don't work as we get the stringified pointer object, e.g.
// "SWIGPointer(0x55dafc88c0a0,owned=0"
if (0) {
    check::equal($t->strlen($pc), 4, "bad multi-arg typemap");
    check::equal($t->ustrlen($pc), 4, "bad multi-arg typemap");
}

// FIXME: Cannot convert pc to string
if (0) {
    var_pchar_set($pc);
} else {
    var_pchar_set("hola");
}
check::equal(var_pchar_get(), "hola", "bad pointer case");

// FIXME: Cannot convert pc to string
if (0) {
    var_namet_set($pc);
} else {
    var_namet_set("hola");
}
check::equal(var_namet_get(), "hola", "bad pointer case");

delete_pchar($pc);

check::done();
