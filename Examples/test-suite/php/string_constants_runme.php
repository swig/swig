<?php

require "tests.php";

// No new functions
check::functions(array());
// New classes
check::classes(array('string_constants', 'things'));
// New vars
check::globals(array('AA3', 'EE3', 'ES3', 'PR3', 'QQ3', 'SS3', 'XX3', 'ZS3'));

check::equal(string_constants::QQ1, "\01000! \0018b00!");
check::equal(string_constants::QQ2, "\01000! \0018b00!");
check::equal(QQ3_get(), "\01000! \0018b00!");
$t = new things();
check::equal($t->defarguments7(), "\01000! \0018b00!");

check::done();
