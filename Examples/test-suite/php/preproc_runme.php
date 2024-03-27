<?php

require "tests.php";

// New functions
check::functions(array('hello0','hello1','hello2','f','test','method','methodX','foo_func','foo_func2','bar_func2'));
// New classes
check::classes(array('preproc','EmbeddedDefines','TypeNameTraits','tcxMessageTest','tcxMessageBug'));
// No new vars
check::globals(array('endif_','define','defined','FOO','BAR','global_var','global_var2'));

check::equal(preproc::endif__get(), 1);
check::equal(preproc::define_get(), 1);
check::equal(preproc::defined_get(), 1);

check::equal(2 * preproc::one, preproc::two);

check::equal(preproc::methodX(99), 199);

$t1 = new tcxMessageTest();
$t2 = new tcxMessageBug();
