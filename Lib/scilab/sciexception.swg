/*
 * Exception typemaps (throws)
 */

%typemap(throws, noblock=1) int, unsigned int, signed int,
                            int&,unsigned int&, signed int&,
                            long, unsigned long, signed long,
                            short, unsigned short,signed short,
				                    long long, unsigned long long,
				                    unsigned char, signed char,
				                    long&, unsigned long&, signed long&,
				                    short&, unsigned short&, signed short&,
				                    long long&, unsigned long long&,
				                    unsigned char&, signed char& {
  char obj[20];
  sprintf(obj, "%d", $1);
  %raise(obj, "$type", $descriptor);
}

%typemap(throws, noblock=1) enum SWIGTYPE {
  char obj[20];
  sprintf(obj, "%d", $1);
  %raise(obj, "$type", $descriptor);
}

%typemap(throws, noblock=1) float, double,
				                    float&, double& {
  char obj[20];
  sprintf(obj, "%5.3f", $1);
  %raise(obj, "$type", $descriptor);
}

%typemap(throws, noblock=1) char*, char[ANY] {
  %raise($1, "$type", $descriptor);
}

%typemap(throws, noblock=1) SWIGTYPE,
                            SWIGTYPE*,
                            SWIGTYPE [ANY],
                            SWIGTYPE & {
  %raise(NULL, "$type", $descriptor);
}

%typemap(throws, noblock=1) (...) {
  SWIG_exception_fail(SWIG_RuntimeError,"unknown exception");
}
