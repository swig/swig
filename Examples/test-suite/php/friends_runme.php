<?php

require "tests.php";

check::functions(array('globalscope','mix','get_val2','get_val3','bas','baz','get_val1','set','chum_blah','mate_blah','friend_definition','friend_declaration','friend_args_definition','friend_args_declaration','friend_definition_compiler','friend_declaration_compiler','friend_args_definition_compiler','friend_args_declaration_compiler'));
check::classes(array('friends','Foe','A','B','D_i','D_d','CModelParameterCompartment','CModelParameterSpecies','Chum','Mate'));
// No new vars
check::globals(array());

$a = new A(2);

check::equal(get_val1($a), 2);
check::equal(get_val2($a), 4);
check::equal(get_val3($a), 6);

# nice overload working fine
check::equal(get_val1(1, 2, 3), 1);

$b = new B(3);

# David's case
check::equal(mix($a, $b), 5);

$di = new D_i(2);
$dd = new D_d(3.3);

# incredible template overloading working just fine
check::equal(get_val1($di), 2);
check::equal(get_val1($dd), 3.3);

set($di, 4);
set($dd, 1.3);

check::equal(get_val1($di), 4);
check::equal(get_val1($dd), 1.3);

check::equal(chum_blah(), 1234);
check::equal(mate_blah(), 4321);

$foe = new Foe(111);
check::equal(friend_definition(), 10);
check::equal(friend_declaration(), 11);
check::equal(friend_args_definition($foe), 111);
check::equal(friend_args_declaration($foe), 111);

check::equal(friend_definition_compiler(), 20);
check::equal(friend_declaration_compiler(), 21);
check::equal(friend_args_definition_compiler($foe), 111);
check::equal(friend_args_declaration_compiler($foe), 111);

check::done();
