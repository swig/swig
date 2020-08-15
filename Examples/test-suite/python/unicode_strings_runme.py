import sys

import unicode_strings

if sys.version_info[0:2] >= (3, 1):
    test_string = "h\udce9llo w\u00f6rld"
    if unicode_strings.non_utf8_c_str() != test_string:
        raise ValueError("Test comparison mismatch")
    if unicode_strings.non_utf8_std_string() != test_string:
        raise ValueError("Test comparison mismatch")

def check(s1, s2):
    if s1 != s2:
        raise RuntimeError("{} != {}".format(s1, s2))

# Testing SWIG_PYTHON_2_UNICODE flag which allows unicode strings to be passed to C
if sys.version_info[0:2] < (3, 0):
    check(unicode_strings.charstring("hello1"), "hello1")
    check(unicode_strings.charstring(str(u"hello2")), "hello2")
    check(unicode_strings.charstring(u"hello3"), "hello3")
    check(unicode_strings.charstring(str("hello4")), "hello4")
    unicode_strings.charstring(u"hell\xb05")
    unicode_strings.charstring(u"hell\u00f66")
    low_surrogate_string = u"\udcff"
else:
    low_surrogate_string = "\udcff"

try:
    unicode_strings.instring(low_surrogate_string)
    # Will succeed with Python 2
except TypeError as e:
    # Python 3 will fail the PyUnicode_AsUTF8String conversion resulting in a TypeError.
    # The real error is actually:
    # UnicodeEncodeError: 'utf-8' codec can't encode character '\udcff' in position 0: surrogates not allowed
    pass
