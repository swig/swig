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

static const char globchar0 = '\0';
static const char globchar1 = '\1';
static const char globchar2 = '\n';
static const char globcharA = 'A';
static const char globcharB = '\102'; // B
static const char globcharC = '\x43'; // C
static const char globcharD = 0x44; // D
static const char globcharE = 69; // E

struct CharTestClass {
  static const char memberchar0 = '\0';
  static const char memberchar1 = '\1';
  static const char memberchar2 = '\n';
  static const char membercharA = 'A';
  static const char membercharB = '\102'; // B
  static const char membercharC = '\x43'; // C
  static const char membercharD = 0x44; // D
  static const char membercharE = 69; // E
};
%}
