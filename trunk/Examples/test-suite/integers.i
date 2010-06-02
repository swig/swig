/* This test case is meant to be used with run tests that check that
   -- the whole range of the integer types is supported;
   -- errors are signalled when out-of-range values are passed.
*/

%module integers;

%inline %{
  signed char signed_char_identity(signed char x) { return x; }
  unsigned char unsigned_char_identity(unsigned char x) { return x; }
  signed short signed_short_identity(signed short x) { return x; }
  unsigned short unsigned_short_identity(unsigned short x) { return x; }
  signed int signed_int_identity(signed int x) { return x; }
  unsigned int unsigned_int_identity(unsigned int x) { return x; }
  signed long signed_long_identity(signed long x) { return x; }
  unsigned long unsigned_long_identity(unsigned long x) { return x; }
  signed long long signed_long_long_identity(signed long long x) { return x; }
  unsigned long long unsigned_long_long_identity(unsigned long long x) { return x; }
%}

