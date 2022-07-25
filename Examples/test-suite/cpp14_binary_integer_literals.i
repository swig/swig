%module cpp14_binary_integer_literals

#if 0b100 < 4
# error binary constant in preprocessor expression failed
#endif

%inline %{
int b1 = 0b1;
int b2 = 0b10;
long b3 = 0b11l;
unsigned long b4 = 0b100ul;
unsigned long b5 = 0B101UL;
%}
