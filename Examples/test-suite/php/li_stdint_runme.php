<?php

require "tests.php";

// New functions
check::functions(array(
    'int8_td', 'int16_td', 'int32_td', 'int64_td',
    'uint8_td', 'uint16_td', 'uint32_td', 'uint64_td',
    'int_fast8_td', 'int_fast16_td', 'int_fast32_td', 'int_fast64_td',
    'uint_fast8_td', 'uint_fast16_td', 'uint_fast32_td', 'uint_fast64_td',
    'int_least8_td', 'int_least16_td', 'int_least32_td', 'int_least64_td',
    'uint_least8_td', 'uint_least16_td', 'uint_least32_td', 'uint_least64_td'
));
// New classes
check::classes(array('li_stdint', 'StdI', 'StdIf', 'StdIl'));
// No new vars
check::globals(array());

check::equal(int8_td(127), 127);
check::equal(int8_td(-128), -128);
check::equal(int16_td(32767), 32767);
check::equal(int16_td(-32767), -32767);
check::equal(int32_td(42), 42);
check::equal(int32_td(-42), -42);
check::equal(int64_td(42), 42);
check::equal(int64_td(-42), -42);

check::equal(uint8_td(255), 255);
check::equal(uint8_td(0), 0);
check::equal(uint16_td(65535), 65535);
check::equal(uint16_td(0), 0);
check::equal(uint32_td(42), 42);
check::equal(uint32_td(0), 0);
check::equal(uint64_td(42), 42);
check::equal(uint64_td(0), 0);

check::equal(int_fast8_td(127), 127);
check::equal(int_fast8_td(-128), -128);
check::equal(int_fast16_td(32767), 32767);
check::equal(int_fast16_td(-32767), -32767);
check::equal(int_fast32_td(42), 42);
check::equal(int_fast32_td(-42), -42);
check::equal(int_fast64_td(42), 42);
check::equal(int_fast64_td(-42), -42);

check::equal(uint_fast8_td(255), 255);
check::equal(uint_fast8_td(0), 0);
check::equal(uint_fast16_td(65535), 65535);
check::equal(uint_fast16_td(0), 0);
check::equal(uint_fast32_td(42), 42);
check::equal(uint_fast32_td(0), 0);
check::equal(uint_fast64_td(42), 42);
check::equal(uint_fast64_td(0), 0);

check::equal(int_least8_td(127), 127);
check::equal(int_least8_td(-128), -128);
check::equal(int_least16_td(32767), 32767);
check::equal(int_least16_td(-32767), -32767);
check::equal(int_least32_td(42), 42);
check::equal(int_least32_td(-42), -42);
check::equal(int_least64_td(42), 42);
check::equal(int_least64_td(-42), -42);

check::equal(uint_least8_td(255), 255);
check::equal(uint_least8_td(0), 0);
check::equal(uint_least16_td(65535), 65535);
check::equal(uint_least16_td(0), 0);
check::equal(uint_least32_td(42), 42);
check::equal(uint_least32_td(0), 0);
check::equal(uint_least64_td(42), 42);
check::equal(uint_least64_td(0), 0);
