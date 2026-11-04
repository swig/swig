// Test for %typemap(ignore)

%module ignore_parameter

%typemap(in,numinputs=0) char* a %{
  /* Catch if a target language substitutes this typemap more than once in
   * the same wrapper method - this will lead to an error due to this label
   * being redefined.
   */
  goto redefinition_error_means_in_typemap_substituted_more_than_once;
  redefinition_error_means_in_typemap_substituted_more_than_once:
  undefined_error_means_in_typemap_a_not_substituted:
  $1 = const_cast<char *>("hello");
%}
%typemap(in,numinputs=0) int bb "undefined_error_means_in_typemap_bb_not_substituted: $1 = 101; called_argout = 0; called_freearg = 0;"
%typemap(in,numinputs=0) double ccc "undefined_error_means_in_typemap_ccc_not_substituted: $1 = 8.8;"

// Catch if a target language does not substitute the typemaps above, at the start, in the middle or at the end of the parameters
%typemap(check) char* a "if (0) goto undefined_error_means_in_typemap_a_not_substituted;"
%typemap(check) int bb "if (0) goto undefined_error_means_in_typemap_bb_not_substituted;"
%typemap(check) double ccc "if (0) goto undefined_error_means_in_typemap_ccc_not_substituted;"

%typemap(freearg) char* a "" // ensure freearg is not generated (needed for Java at least)

%typemap(argout) int bb "called_argout = 1;"
%typemap(freearg) int bb "called_freearg = 1;"

// A library freearg typemap for the type, such as one freeing an 'int *' converted by a library 'in' typemap, must not be used
%typemap(in,numinputs=0) int *dd (int temp) "temp = 5; $1 = &temp;"

%ignore unignorable;
// Don't let SWIG expand this function with its default parameter: instead,
// always "require" the version of the function with a single argument, but
// then ignore it using `numinputs=0`.
%ignore audi();

%inline %{
// constant for detecting correct "argout" call
int called_argout = 0;
int called_freearg = 0;

// global function tests
char* jaguar(char* a, int b, double c) { return a; }
int lotus(char* aa, int bb, double cc) { return bb; }
double tvr(char* aaa, int bbb, double ccc) { return ccc; }
int ferrari(int bb) { return bb; }
int fiat(int unignorable) { return unignorable; }
int peugeot(int *dd) { return *dd; }

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



