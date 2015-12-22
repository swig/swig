import sys

import unicode_strings

# The 'u' string prefix isn't valid in Python 3.0 - 3.2 and is redundant
# in 3.3+. Since this file is run through 2to3 before testing, though,
# mark this as a unicode string in 2.x so it'll become a str in 3.x.
test_string = u'h\udce9llo w\u00f6rld'

if sys.version_info[0:2] >= (3, 1):
    if unicode_strings.non_utf8_c_str() != test_string:
        raise ValueError('Test comparison mismatch')
    if unicode_strings.non_utf8_std_string() != test_string:
        raise ValueError('Test comparison mismatch')

# Testing SWIG_PYTHON_2_UNICODE flag which allows unicode strings to be passed to C
if sys.version_info[0:2] < (3, 0):
    assert unicode_strings.charstring("hello1") == "hello1"
    assert unicode_strings.charstring(str(u"hello2")) == "hello2"
    assert unicode_strings.charstring(u"hello3") == "hello3"
    assert unicode_strings.charstring(unicode("hello4")) == "hello4"
    unicode_strings.charstring(u"hell\xb05")
    unicode_strings.charstring(u"hell\u00f66")
