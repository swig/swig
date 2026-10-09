module string_constants_runme;

import std.exception;
import string_constants.string_constants;

void main() {
  enforce(OL1 == "\300\242", "OL1 failed");
  enforce(WS6 == "\u00C6\"\U0001F600\u00E97"w, "WS6 failed");
  enforce(WC6 == '\u00C6', "WC6 failed");
}
