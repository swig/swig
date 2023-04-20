<?php

require "tests.php";

// New functions
check::functions(array('noReturn','noDiscard','noDiscardDeprecated','maybeUnused1','maybeUnused2','likely','test_string_literal'));
// New classes
check::classes(array('cpp11_attribute_specifiers','S'));
// No new vars
check::globals(array());

check::equal(test_string_literal(), 'Test [[ and ]] in string literal', "test_string_literal() wrong");

check::done();
