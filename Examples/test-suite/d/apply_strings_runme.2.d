module apply_strings_runme;

import apply_strings.apply_strings;

enum string TEST_MESSAGE = "A message from target language to the C++ world and back again.";

void main() {
  if (UCharFunction(TEST_MESSAGE) != TEST_MESSAGE) throw new Exception("UCharFunction failed");
  if (SCharFunction(TEST_MESSAGE) != TEST_MESSAGE) throw new Exception("SCharFunction failed");
  auto pChar = CharFunction(null);
  if (pChar !is null) throw new Exception("CharFunction failed");
}
