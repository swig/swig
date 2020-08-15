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
    # Python 3.0-3.2 results in a SyntaxError when using u"" string literals, so we use a
    # convoluted unicode string construction using unicode() and unichr().
    # Conventional Python 2 syntax shown in comments.
    check(unicode_strings.charstring("hello1"), "hello1")
    check(unicode_strings.charstring(str(unicode("hello2"))), "hello2") # u"hello2"
    check(unicode_strings.charstring(unicode("hello3")), "hello3") # u"hello3"
    check(unicode_strings.charstring(str("hello4")), "hello4")
    unicode_strings.charstring(unicode("hell" + unichr(0xb0) + "5")) # u"hell\xb05"
    unicode_strings.charstring(unicode("hell" + unichr(0x00f6) +"6")) # u"hell\u00f66"
    low_surrogate_string = unichr(0xdcff) # u"\udcff"
    unicode_strings.instring(low_surrogate_string)
else:
    low_surrogate_string = "\udcff"
    try:
        unicode_strings.instring(low_surrogate_string)
        raise RuntimeError("Exception should have been thrown")
    except TypeError as e:
        # Python 3 will fail the PyUnicode_AsUTF8String conversion resulting in a TypeError.
        # The real error is actually:
        # UnicodeEncodeError: 'utf-8' codec can't encode character '\udcff' in position 0: surrogates not allowed
        pass
