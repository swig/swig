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

    low_surrogate_string = "\udcff"
    try:
        unicode_strings.instring(low_surrogate_string)
        raise RuntimeError("Exception should have been thrown")
    except TypeError as e:
        # Python 3 will fail the PyUnicode_AsUTF8String conversion resulting in a TypeError.
        # The real error is actually:
        # UnicodeEncodeError: 'utf-8' codec can't encode character '\udcff' in position 0: surrogates not allowed
        pass
