<?php

require "tests.php";

$CPLUSPLUS_MSG = "A message from the deep dark world of C++, where anything is possible.";
$OTHERLAND_MSG_10 = "Little message from the safe world.10";

check::equal(GetCharHeapString(), $CPLUSPLUS_MSG, "failed GetCharHeapString");
check::equal(GetConstCharProgramCodeString(), $CPLUSPLUS_MSG, "failed GetConstCharProgramCodeString");
check::equal(GetCharStaticString(), $CPLUSPLUS_MSG, "failed GetCharStaticString");
check::equal(GetCharStaticStringFixed(), $CPLUSPLUS_MSG, "failed GetCharStaticStringFixed");
check::equal(GetConstCharStaticStringFixed(), $CPLUSPLUS_MSG, "failed GetConstCharStaticStringFixed");

check::equal(SetCharHeapString($OTHERLAND_MSG_10, 10), true, "failed GetConstCharStaticStringFixed");
check::equal(SetCharStaticString($OTHERLAND_MSG_10, 10), true, "failed SetCharStaticString");
check::equal(SetCharArrayStaticString($OTHERLAND_MSG_10, 10), true, "failed SetCharArrayStaticString");
check::equal(SetConstCharHeapString($OTHERLAND_MSG_10, 10), true, "failed SetConstCharHeapString");
check::equal(SetConstCharStaticString($OTHERLAND_MSG_10, 10), true, "failed SetConstCharStaticString");
check::equal(SetConstCharArrayStaticString($OTHERLAND_MSG_10, 10), true, "failed SetConstCharArrayStaticString");
check::equal(SetCharConstStaticString($OTHERLAND_MSG_10, 10), true, "failed SetCharConstStaticString");
check::equal(SetConstCharConstStaticString($OTHERLAND_MSG_10, 10), true, "failed SetConstCharConstStaticString");
check::equal(SetConstCharTypedefString($OTHERLAND_MSG_10, 10), true, "failed SetConstCharTypedefString");

check::equal(CharPingPong($OTHERLAND_MSG_10), $OTHERLAND_MSG_10, "failed CharPingPong");
check::equal(CharArrayPingPong($OTHERLAND_MSG_10), $OTHERLAND_MSG_10, "failed CharArrayPingPong");
check::equal(CharArrayDimsPingPong("Ping10"), "Ping10", "failed CharArrayDimsPingPong");

check::equal(CharArrayDimsLength("Ping"), 4, "failed CharArrayDimsLength");
check::equal(CharArrayDimsLength("0123456789abcde"), 15, "failed CharArrayDimsLength");
try {
  CharArrayDimsLength("0123456789abcdef");
  check::fail("CharArrayDimsLength overlong string");
} catch (ValueError $e) {
}

Global_char_set($OTHERLAND_MSG_10);
check::equal(Global_char_get(), $OTHERLAND_MSG_10, "failed Global_char_get");

// global_char_array1 is a char[] with no size, so it is read only
check::equal(function_exists('global_char_array1_set'), false, "global_char_array1 has a setter");
check::equal(Global_char_array1_get(), $CPLUSPLUS_MSG, "failed Global_char_array1_get");

Global_char_array2_set($OTHERLAND_MSG_10);
check::equal(Global_char_array2_get(), $OTHERLAND_MSG_10, "failed Global_char_array2_get");
try {
  Global_char_array2_set($CPLUSPLUS_MSG . $CPLUSPLUS_MSG);
  check::fail("Global_char_array2_set overlong string");
} catch (ValueError $e) {
}

Global_char_one_set("a");
check::equal(Global_char_one_get(), "a", "failed Global_char_one_get");
$one = new CharArrayOne();
$one->one = "b";
check::equal($one->one, "b", "failed CharArrayOne one");

check::equal(CharArrayPingPong(null), null, "failed CharArrayPingPong null");
check::equal(CharArrayDimsPingPong(null), null, "failed CharArrayDimsPingPong null");
foreach ([fn() => Char_array_null_get()->four = null, fn() => Global_char_array_null_set(null)] as $i => $f) {
  try {
    $f();
    check::fail("char array null $i accepted");
  } catch (TypeError $e) {
  }
}
check::equal(Char_array_null_get()->four, "qqq", "failed char array member set to null");
check::equal(Global_char_array_null_get(), "qqq", "failed char array global set to null");

check::equal(Global_const_char_get(), $CPLUSPLUS_MSG, "failed Global_const_char");
check::equal(Global_const_char_array1_get(), $CPLUSPLUS_MSG, "failed Global_const_char_array1");
check::equal(Global_const_char_array2_get(), $CPLUSPLUS_MSG, "failed Global_const_char_array2");

check::equal(GetCharPointerRef(), $CPLUSPLUS_MSG, "failed GetCharPointerRef");
check::equal(SetCharPointerRef($OTHERLAND_MSG_10, 10), true, "failed SetCharPointerRef");
check::equal(GetConstCharPointerRef(), $CPLUSPLUS_MSG, "failed GetConstCharPointerRef");
check::equal(SetConstCharPointerRef($OTHERLAND_MSG_10, 10), true, "failed SetConstCharPointerRef");

check::done();
