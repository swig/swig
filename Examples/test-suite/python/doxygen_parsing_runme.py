#!/usr/bin/python

import doxygen_parsing
import sys
import re

def check(got, expected):
  if not re.match(str(expected), str(got)):
    raise RuntimeError("\n" + "Expected: [" + str(expected) + "]\n" + "Got     : [" + str(got) + "]")

check(doxygen_parsing.simpleFunction.__doc__, '\s+This is simple comment for a function\s+')
check(doxygen_parsing.CSimpleClass.__doc__, '\s+This is simple comment for a class\s+')
check(doxygen_parsing.CSimpleClass.simpleMethod.__doc__, '\s+Simple method\s+')
check(doxygen_parsing.CSimpleClass.simpleMethodWithParameter.__doc__, ''
'\s+Simple method with parameter'
'\s+Arguments:\s+param \(int\)\s+-- Some test param\s+'
'argument \(int\)\s+-- Some test argument\s+'
)
check(doxygen_parsing.CTemplateClassInt.__doc__, '\s+Comment for template class\s+')
check(doxygen_parsing.CTemplateClassInt.templateMethod.__doc__, '\s+Template method\s+')