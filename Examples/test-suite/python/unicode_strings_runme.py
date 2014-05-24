import sys

import unicode_strings

if sys.version_info > (3, 0):
    unicode_strings.non_utf8_c_str()
    unicode_strings.non_utf8_std_string()
