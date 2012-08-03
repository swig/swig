#!/usr/bin/python

import doxygen_basic_translate
import string
import sys

def check(got, expected):
  #if got is Null
  #  raise RuntimeError('Expected comment string\n')
  gotStr = string.replace(got, ' ', '')
  gotStr = string.replace(gotStr, '\n', '')
  gotStr = string.replace(gotStr, '\t', '')
  expectedStr = string.replace(expected, ' ', '')
  expectedStr = string.replace(expectedStr, '\n', '')
  expectedStr = string.replace(expectedStr, '\t', '')
  if not gotStr == expectedStr:
    raise RuntimeError("Expected: [" + str(expected) + "]\n" + "Got     : [" + str(got) + "]\n")

check(doxygen_basic_translate.function.__doc__, ''
'  Brief description.\n'
'  The comment text\n'
'  Authors:\n'
'  Some author\n'
'  Return:\n'
'  Some number\n'
'  See also:\n'
'  function2\n'
)
check(doxygen_basic_translate.function2.__doc__, ''
'  A test of a very very very very very very very very very very very'
'  very very very very very'
'  very very very very very long comment'
'  string.'
)
check(doxygen_basic_translate.function3.__doc__, ''
'  ----------------------------------------------------------------\n'
'  Overload 1:\n'
'  ----------------------------------------------------------------\n'
'  A test for overloaded functions\n'
'  This is function __one__\n'
'  ----------------------------------------------------------------\n'
'  Overload 2:\n'
'  ----------------------------------------------------------------\n'
'  A test for overloaded functions\n'
'  This is function __two__\n'
)
check(doxygen_basic_translate.function4.__doc__, ''
'  A test of some mixed tag usage\n' 
'  If: CONDITION {\n'
'  This _code_fragment shows us something .\n'
'  Title: Minuses:\n'
'   -it\'s senseless\n'
'   -it\'s stupid\n'
'   -it\'s null\n'
'  Warning:\n'
'  This may not work as expected\n'
'  int main() { while(true); }\n'
'  }'
)
check(doxygen_basic_translate.function5.__doc__, ''
'  This is a post comment. \n'
)
check(doxygen_basic_translate.function6.__doc__, ''
'  Test for default args \n'
'  Arguments: \n'
'  a (int) -- Some parameter, default is 42\n'
)
