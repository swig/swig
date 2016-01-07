%module chartest

%inline %{
char printable_global_char = 'a';
char unprintable_global_char = 0x7F;

char GetPrintableChar() {
  return 'a';
}

char GetUnprintableChar() {
  return 0x7F;
}

%}
