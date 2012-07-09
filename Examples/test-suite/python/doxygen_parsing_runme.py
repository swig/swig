#!/usr/bin/python

import doxygen_parsing
import sys
import re

def check(got, expected):
  if not re.match(str(expected), str(got)):
    raise RuntimeError("\n" + "Expected: [" + str(expected) + "]\n" + "Got     : [" + str(got) + "]")

check(doxygen_parsing.someFunction.__doc__, '\s+The function comment\s+')
check(doxygen_parsing.SomeClass.__doc__, '\s+The class comment\s+')
check(doxygen_parsing.SomeStruct.__doc__, '\s+The struct comment\s+')
check(doxygen_parsing.SomeAnotherClass.classMethod.__doc__, '\s+The class method comment\s+')
check(doxygen_parsing.SomeAnotherClass.classMethodExtended.__doc__, ''
'\s+The class method with parameter'
'\s+Arguments:\s+'
'a \(int\)\s+-- Parameter a\s+'
'b \(int\)\s+-- Parameter b\s+'
)
check(doxygen_parsing.SomeAnotherClass.classMethodExtended2.__doc__, ''
'\s+The class method with parameter'
'\s+Arguments:\s+'
'a \(int\)\s+-- Parameter a\s+'
'b \(int\)\s+-- Parameter b\s+'
)
check(doxygen_parsing.SomeAnotherStruct.structMethod.__doc__, '\s+The struct method comment\s+')
check(doxygen_parsing.SomeAnotherStruct.structMethodExtended.__doc__, ''
'\s+The struct method with parameter'
'\s+Arguments:\s+'
'a \(int\)\s+-- Parameter a\s+'
'b \(int\)\s+-- Parameter b\s+'
)
check(doxygen_parsing.SomeAnotherStruct.structMethodExtended2.__doc__, ''
'\s+The struct method with parameter'
'\s+Arguments:\s+'
'a \(int\)\s+-- Parameter a\s+'
'b \(int\)\s+-- Parameter b\s+'
)