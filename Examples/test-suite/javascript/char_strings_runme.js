var char_strings = require("char_strings");

var assertIsEqual = function(expected, actual) {
  if (expected !== actual) {
    throw new Error("Expected "+expected+", was "+actual);
  }
};

assertIsEqual("hi there", char_strings.CharPingPong("hi there"));
assertIsEqual("hi there", char_strings.CharArrayPingPong("hi there"));
assertIsEqual("hi there", char_strings.CharArrayDimsPingPong("hi there"));

assertIsEqual(true, char_strings.SetConstCharTypedefString("Little message from the safe world.10", 10));
