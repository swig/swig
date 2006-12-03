use apply_strings;

my $TEST_MESSAGE = "A message from target language to the C++ world and back again.";

if (apply_strings::UCharFunction($TEST_MESSAGE) ne $TEST_MESSAGE) {
  die "UCharFunction failed";
}
if (apply_strings::SCharFunction($TEST_MESSAGE) ne $TEST_MESSAGE) {
  die "SCharFunction failed";
}
