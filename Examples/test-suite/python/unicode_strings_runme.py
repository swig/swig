import sys

import unicode_strings

# The 'u' string prefix isn't valid in Python 3.0 - 3.2 and is redundant
# in 3.3+. Since this file is run through 2to3 before testing, though,
# mark this as a unicode string in 2.x so it'll become a str in 3.x.
test_string = u'h\udce9llo w\u00f6rld'

if sys.version_info[0:2] >= (3, 1):
    assert unicode_strings.non_utf8_c_str() == test_string
    assert unicode_strings.non_utf8_std_string() == test_string
