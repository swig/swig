<?php

require "tests.php";
require "preproc_constants.php";

check::equal(gettype(preproc_constants::CONST_INT1), "integer", "preproc_constants.CONST_INT1 has unexpected type");
check::equal(gettype(preproc_constants::CONST_INT2), "integer", "preproc_constants.CONST_INT2 has unexpected type");
check::equal(gettype(preproc_constants::CONST_UINT1), "integer", "preproc_constants.CONST_UINT1 has unexpected type");
check::equal(gettype(preproc_constants::CONST_UINT2), "integer", "preproc_constants.CONST_UINT2 has unexpected type");
check::equal(gettype(preproc_constants::CONST_UINT3), "integer", "preproc_constants.CONST_UINT3 has unexpected type");
check::equal(gettype(preproc_constants::CONST_UINT4), "integer", "preproc_constants.CONST_UINT4 has unexpected type");
check::equal(gettype(preproc_constants::CONST_LONG1), "integer", "preproc_constants.CONST_LONG1 has unexpected type");
check::equal(gettype(preproc_constants::CONST_LONG2), "integer", "preproc_constants.CONST_LONG2 has unexpected type");
check::equal(gettype(preproc_constants::CONST_LONG3), "integer", "preproc_constants.CONST_LONG3 has unexpected type");
check::equal(gettype(preproc_constants::CONST_LONG4), "integer", "preproc_constants.CONST_LONG4 has unexpected type");
# On some platforms these don't fit in a PHP integer and so get wrapped as a string constant.
#check::equal(gettype(preproc_constants::CONST_LLONG1), "integer", "preproc_constants.CONST_LLONG1 has unexpected type");
#check::equal(gettype(preproc_constants::CONST_LLONG2), "integer", "preproc_constants.CONST_LLONG2 has unexpected type");
#check::equal(gettype(preproc_constants::CONST_LLONG3), "integer", "preproc_constants.CONST_LLONG3 has unexpected type");
#check::equal(gettype(preproc_constants::CONST_LLONG4), "integer", "preproc_constants.CONST_LLONG4 has unexpected type");
#check::equal(gettype(preproc_constants::CONST_ULLONG1), "integer", "preproc_constants.CONST_ULLONG1 has unexpected type");
#check::equal(gettype(preproc_constants::CONST_ULLONG2), "integer", "preproc_constants.CONST_ULLONG2 has unexpected type");
#check::equal(gettype(preproc_constants::CONST_ULLONG3), "integer", "preproc_constants.CONST_ULLONG3 has unexpected type");
#check::equal(gettype(preproc_constants::CONST_ULLONG4), "integer", "preproc_constants.CONST_ULLONG4 has unexpected type");
check::equal(gettype(preproc_constants::CONST_DOUBLE1), "double", "preproc_constants.CONST_DOUBLE1 has unexpected type");
check::equal(gettype(preproc_constants::CONST_DOUBLE2), "double", "preproc_constants.CONST_DOUBLE2 has unexpected type");
check::equal(gettype(preproc_constants::CONST_DOUBLE3), "double", "preproc_constants.CONST_DOUBLE3 has unexpected type");
check::equal(gettype(preproc_constants::CONST_DOUBLE4), "double", "preproc_constants.CONST_DOUBLE4 has unexpected type");
check::equal(gettype(preproc_constants::CONST_DOUBLE5), "double", "preproc_constants.CONST_DOUBLE5 has unexpected type");
check::equal(gettype(preproc_constants::CONST_DOUBLE6), "double", "preproc_constants.CONST_DOUBLE6 has unexpected type");
check::equal(gettype(preproc_constants::CONST_BOOL1), "boolean", "preproc_constants.CONST_BOOL1 has unexpected type");
check::equal(gettype(preproc_constants::CONST_BOOL2), "boolean", "preproc_constants.CONST_BOOL2 has unexpected type");
check::equal(gettype(preproc_constants::CONST_CHAR), "string", "preproc_constants.CONST_CHAR has unexpected type");
check::equal(gettype(preproc_constants::CONST_STRING1), "string", "preproc_constants.CONST_STRING1 has unexpected type");
check::equal(gettype(preproc_constants::CONST_STRING2), "string", "preproc_constants.CONST_STRING2 has unexpected type");

check::equal(gettype(preproc_constants::INT_AND_BOOL), "integer", "preproc_constants.INT_AND_BOOL has unexpected type");
check::equal(gettype(preproc_constants::INT_AND_CHAR), "integer", "preproc_constants.INT_AND_CHAR has unexpected type");
check::equal(gettype(preproc_constants::INT_AND_INT), "integer", "preproc_constants.INT_AND_INT has unexpected type");
check::equal(gettype(preproc_constants::INT_AND_UINT), "integer", "preproc_constants.INT_AND_UINT has unexpected type");
check::equal(gettype(preproc_constants::INT_AND_LONG), "integer", "preproc_constants.INT_AND_LONG has unexpected type");
check::equal(gettype(preproc_constants::INT_AND_ULONG), "integer", "preproc_constants.INT_AND_ULONG has unexpected type");
# On some platforms these don't fit in a PHP integer and so get wrapped as a string constant.
#check::equal(gettype(preproc_constants::INT_AND_LLONG), "integer", "preproc_constants.INT_AND_LLONG has unexpected type");
#check::equal(gettype(preproc_constants::INT_AND_ULLONG), "integer", "preproc_constants.INT_AND_ULLONG has unexpected type");
check::equal(gettype(preproc_constants::BOOL_AND_BOOL), "integer", "preproc_constants.BOOL_AND_BOOL has unexpected type");

check::equal(gettype(preproc_constants::EXPR_MULTIPLY), "integer", "preproc_constants.EXPR_MULTIPLY has unexpected type");
check::equal(gettype(preproc_constants::EXPR_DIVIDE), "integer", "preproc_constants.EXPR_DIVIDE has unexpected type");
check::equal(gettype(preproc_constants::EXPR_PLUS), "integer", "preproc_constants.EXPR_PLUS has unexpected type");
check::equal(gettype(preproc_constants::EXPR_MINUS), "integer", "preproc_constants.EXPR_MINUS has unexpected type");
check::equal(gettype(preproc_constants::EXPR_LSHIFT), "integer", "preproc_constants.EXPR_LSHIFT has unexpected type");
check::equal(gettype(preproc_constants::EXPR_RSHIFT), "integer", "preproc_constants.EXPR_RSHIFT has unexpected type");
check::equal(gettype(preproc_constants::EXPR_LTE), "boolean", "preproc_constants.EXPR_LTE has unexpected type");
check::equal(gettype(preproc_constants::EXPR_GTE), "boolean", "preproc_constants.EXPR_GTE has unexpected type");
check::equal(gettype(preproc_constants::EXPR_INEQUALITY), "boolean", "preproc_constants.EXPR_INEQUALITY has unexpected type");
check::equal(gettype(preproc_constants::EXPR_EQUALITY), "boolean", "preproc_constants.EXPR_EQUALITY has unexpected type");
check::equal(gettype(preproc_constants::EXPR_AND), "integer", "preproc_constants.EXPR_AND has unexpected type");
check::equal(gettype(preproc_constants::EXPR_XOR), "integer", "preproc_constants.EXPR_XOR has unexpected type");
check::equal(gettype(preproc_constants::EXPR_OR), "integer", "preproc_constants.EXPR_OR has unexpected type");
check::equal(gettype(preproc_constants::EXPR_LAND), "boolean", "preproc_constants.EXPR_LAND has unexpected type");
check::equal(gettype(preproc_constants::EXPR_LOR), "boolean", "preproc_constants.EXPR_LOR has unexpected type");
check::equal(gettype(preproc_constants::EXPR_CONDITIONAL), "double", "preproc_constants.EXPR_CONDITIONAL has unexpected type");
check::equal(gettype(preproc_constants::EXPR_MIXED1), "double", "preproc_constants.EXPR_MIXED1 has unexpected type");
check::equal(gettype(preproc_constants::EXPR_WCHAR_MAX), "integer", "preproc_constants.EXPR_WCHAR_MAX has unexpected type");
check::equal(gettype(preproc_constants::EXPR_WCHAR_MIN), "integer", "preproc_constants.EXPR_WCHAR_MIN has unexpected type");

?>
