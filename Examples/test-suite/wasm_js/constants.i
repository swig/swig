%module constants
#define MACRO_TEXT "literal\ntext"
#define MACRO_EXPRESSION (3 * 7)
%constant const char *NULL_TEXT = 0;
%constant bool FLAG = true;
%constant char LETTER = 'Z';
%constant long long WIDE = -9223372036854775807LL;
%constant unsigned long long UWIDE = 18446744073709551615ULL;
%inline %{
enum State { READY = 3, DONE = 9 };
%}
%constant State DEFAULT_STATE = READY;
