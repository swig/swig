import python_strict_unicode

test_bytes   = b"hello \x01world\x99"
BYTES        = b"BYTES"
test_unicode = u"h\udce9llo w\u00f6rld"

# Test that byte string inputs and outputs work as expected
bdbl = python_strict_unicode.double_str(test_bytes)
if bdbl != test_bytes + test_bytes:
    raise RuntimeError("Failed to double string")
if type(bdbl) != type(BYTES):
    raise RuntimeError("Wrong type output for string")
bout = python_strict_unicode.same_str(test_bytes)
if bout != test_bytes:
    raise RuntimeError("Failed to copy char*")
if type(bout) != type(BYTES):
    raise RuntimeError("Wrong type output for char*")

# Test that unicode string inputs and outputs work as expected
udbl = python_strict_unicode.double_wstr(test_unicode)
if udbl != test_unicode + test_unicode:
    raise RuntimeError("Failed to double wide string")
if type(udbl) != type(u""):
    raise RuntimeError("Wrong type output for wide string")
uout = python_strict_unicode.same_wstr(test_unicode)
if uout != test_unicode:
    raise RuntimeError("Failed to copy wchar_t*")
if type(uout) != type(u""):
    raise RuntimeError("Wrong type output for wchar_t*")

# Test that overloading is handled properly
bovr = python_strict_unicode.overload(test_bytes)
if bovr != BYTES:
    raise RuntimeError("Failed to return bytes from overload")
if type(bovr) != type(BYTES):
    raise RuntimeError("Wrong type output from overload")
uovr = python_strict_unicode.overload(test_unicode)
if uovr != u"UNICODE":
    raise RuntimeError("Failed to return unicode from overload")
if type(uovr) != type(u""):
    raise RuntimeERror("Wrong type output from overload")

# Test that bytes aren't accepted as wide strings and unicode isn't accepted as narrow strings
try:
    python_strict_unicode.double_str(test_unicode)
    error = 1
except TypeError:
    error = 0
if error:
    raise RuntimeError("Unicode accepted for string")
try:
    python_strict_unicode.same_str(test_unicode)
    error = 1
except TypeError:
    error = 0
if error:
    raise RuntimeError("Unicode accepted for char*")
try:
    python_strict_unicode.double_wstr(test_bytes)
    error = 1
except TypeError:
    error = 0
if error:
    raise RuntimeError("Bytes accepted for wstring")
try:
    python_strict_unicode.same_wstr(test_bytes)
    error = 1
except TypeError:
    error = 0
if error:
    raise RuntimeError("Bytes accepted for wchar_t*")
