<?php

require "tests.php";

// New functions
check::functions(array(
  '_noret_noReturn',
  '_noDiscard',
  '_noDiscardDeprecated',
  'maybeUnused1',
  'maybeUnused2',
  '_likely',
  'test_string_literal',
  '_noReturnNoDiscard',
  'visible',
  'test_fn'
));
// New classes
check::classes(array('cpp11_attribute_specifiers','S'));
// No new vars
check::globals(array('aligned_var_1', 'aligned_var_2'));

check::equal(test_string_literal(), 'Test [[ and ]] in string literal', "test_string_literal() wrong");

check::done();
