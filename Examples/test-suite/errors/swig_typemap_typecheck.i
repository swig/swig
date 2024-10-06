%module xxx

%typemap(in) Integer x {
  $1 = 0;
}

void overloaded(const char *c);
void overloaded(Integer x, double d);
