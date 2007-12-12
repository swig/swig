use char_strings;

my $val1 = 100;
if (char_strings::CharPingPong($val1) != "100") {
  die "failed";
}

my $val2 = "greetings";
if (char_strings::CharPingPong($val2) != "greetings") {
  die "failed";
}

