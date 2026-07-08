require("char_strings")

assert (char_strings.CharPingPong("hi there") == "hi there")
assert (char_strings.CharPingPong(nil) == nil)

assert (char_strings.CharArrayPingPong("hi there") == "hi there")
assert (char_strings.CharArrayPingPong(nil) == nil)

assert (char_strings.CharArrayDimsPingPong("hi there") == "hi there")
assert (char_strings.CharArrayDimsPingPong(nil) == nil)

assert (char_strings.SetConstCharTypedefString("Little message from the safe world.10", 10))
