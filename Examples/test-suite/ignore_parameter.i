// Test for %typemap(ignore)

%module ignore_parameter

%typemap(in,numinputs=0) char* a "static const char* hi = \"hello\"; $1 = const_cast<char *>(hi);"
%typemap(in,numinputs=0) int bb "$1 = 101; called_argout = 0;"
%typemap(in,numinputs=0) double ccc "$1 = 8.8;"

%typemap(freearg) char* a "" // ensure freearg is not generated (needed for Java at least)

%typemap(argout) int bb "called_argout = 1;"

%ignore unignorable;
// Don't let SWIG expand this function with its default parameter: instead,
// always "require" the version of the function with a single argument, but
// then ignore it using `numinputs=0`.
%ignore audi();

%inline %{
// constant for detecting correct "argout" call
int called_argout = 0;

// global function tests
char* jaguar(char* a, int b, double c) { return a; }
int lotus(char* aa, int bb, double cc) { return bb; }
double tvr(char* aaa, int bbb, double ccc) { return ccc; }
int ferrari(int bb) { return bb; }
int fiat(int unignorable) { return unignorable; }

// member function tests
struct SportsCars {
  char* daimler(char* a, int b, double c) { return a; }
  int astonmartin(char* aa, int bb, double cc) { return bb; }
  double bugatti(char* aaa, int bbb, double ccc) { return ccc; }
  int lamborghini(int bb) { return bb; }
  int maseratti(int unignorable) { return unignorable; }
  double audi(double ccc=9.5) { return ccc; }
};

// constructor tests
struct MiniCooper {
    MiniCooper(char* a, int b, double c) {}
};
struct MorrisMinor {
    MorrisMinor(char* aa, int bb, double cc) {}
};
struct FordAnglia {
    FordAnglia(char* aaa, int bbb, double ccc) {}
};
struct AustinAllegro {
    AustinAllegro(int bb) {}
};
%}



