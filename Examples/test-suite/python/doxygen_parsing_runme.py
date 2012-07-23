#!/usr/bin/python

import doxygen_parsing
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

check(doxygen_parsing.someFunction.__doc__, 'The function comment')
check(doxygen_parsing.SomeClass.__doc__, 'The class comment')
check(doxygen_parsing.SomeStruct.__doc__, 'The struct comment')
check(doxygen_parsing.SomeAnotherClass.classMethod.__doc__, 'The class method comment')
check(doxygen_parsing.SomeAnotherClass.classMethodExtended.__doc__, ''
'The class method with parameter\n'
'Arguments:\n'
'a (int) -- Parameter a\n'
'b (int) -- Parameter b\n'
)
check(doxygen_parsing.SomeAnotherClass.classMethodExtended2.__doc__, ''
'The class method with parameter\n'
'Arguments:\n'
'a (int)-- Parameter a\n'
'b (int)-- Parameter b\n'
)
check(doxygen_parsing.SomeAnotherStruct.structMethod.__doc__, 'The struct method comment')
check(doxygen_parsing.SomeAnotherStruct.structMethodExtended.__doc__, ''
'The struct method with parameter\n'
'Arguments:\n'
'a (int)-- Parameter a\n'
'b (int)-- Parameter b\n'
)
check(doxygen_parsing.SomeAnotherStruct.structMethodExtended2.__doc__, ''
'The struct method with parameter\n'
'Arguments:\n'
'a (int)-- Parameter a\n'
'b (int)-- Parameter b\n'
)