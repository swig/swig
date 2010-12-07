// Checks if the long long and unsigned long long types work.
module long_long_runme;

import Integer = tango.text.convert.Integer;
import long_long.long_long;

void main() {
  check_ll(0L);
  check_ll(0x7FFFFFFFFFFFFFFFL);
  check_ll(-10L);

  check_ull(0u);
  check_ull(127u);
  check_ull(128u);
  check_ull(9223372036854775807u); //0x7FFFFFFFFFFFFFFFL
  check_ull(18446744073709551615u); //0xFFFFFFFFFFFFFFFFL
}

void check_ll(long value) {
  ll = value;
  long value_check = ll;
  if (value != value_check) {
    throw new Exception("Runtime test using long long failed: expected: " ~
      Integer.toString(value) ~ ", got: " ~ Integer.toString(value_check));
  }
}

void check_ull(ulong value) {
  ull = value;
  ulong value_check = ull;
  if (value != value_check) {
    throw new Exception( "Runtime test using unsigned long long failed: expected: " ~
      Integer.toString(value) ~ ", ll_check=" ~ Integer.toString(value_check));
  }
}
