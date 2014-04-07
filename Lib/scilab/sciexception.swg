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
				                    unsigned char&, signed char&,
                            size_t, size_t&,
                            ptrdiff_t, ptrdiff_t& {
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

%typemap(throws, noblock=1) bool, bool& {
  %raise($1 ? "true" : "false", "$type", $descriptor);
}

%typemap(throws, noblock=1) char*, char[ANY] {
  %raise($1, "$type", $descriptor);
}

%typemap(throws, noblock=1) char, char& {
  char obj[1];
  sprintf(obj, "%c", $1);
  %raise(obj, "$type", $descriptor);
}

%typemap(throws, noblock=1) SWIGTYPE,
                            SWIGTYPE*,
                            SWIGTYPE [ANY],
                            SWIGTYPE & {
  %raise((char*)NULL, "$type", $descriptor);
}

%typemap(throws, noblock=1) (...) {
  SWIG_exception_fail(SWIG_RuntimeError,"unknown exception");
}
