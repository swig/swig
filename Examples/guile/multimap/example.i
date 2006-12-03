/* File : example.i */
%module example

%{
extern int gcd(int x, int y);
extern int gcdmain(int argc, char *argv[]);
extern int count(char *bytes, int len, char c);
extern void capitalize (char *str, int len);
extern void circle (double cx, double cy);
extern int squareCubed (int n, int *OUTPUT);
%}

%include exception.i
%include typemaps.i

extern int    gcd(int x, int y);

%typemap(in) (int argc, char *argv[]) {
  int i;
  SCM *v;
  if (!(SCM_NIMP($input) && SCM_VECTORP($input))) {
    SWIG_exception(SWIG_ValueError, "Expecting a vector");
    return;
  }
  $1 = SCM_LENGTH($input);
  if ($1 == 0) {
    SWIG_exception(SWIG_ValueError, "Vector must contain at least 1 element");
  }
  $2 = (char **) malloc(($1+1)*sizeof(char *));
  v = SCM_VELTS($input);
  for (i = 0; i < $1; i++) {
    if (!(SCM_NIMP(v[i]) && SCM_STRINGP(v[i]))) {
      free($2);	
      SWIG_exception(SWIG_ValueError, "Vector items must be strings");
      return;
    }
    $2[i] = SCM_CHARS(v[i]);
  }
  $2[i] = 0;
}

%typemap(freearg) (int argc, char *argv[]) {
   free($2);
}

extern int gcdmain(int argc, char *argv[]);

%typemap(in) (char *bytes, int len) {
  if (!(SCM_NIMP($input) && SCM_STRINGP($input))) {
    SWIG_exception(SWIG_ValueError, "Expecting a string");
  }
  $1 = SCM_CHARS($input);
  $2 = SCM_LENGTH($input);
}

extern int count(char *bytes, int len, char c);

/* This example shows how to wrap a function that mutates a string */

%typemap(in) (char *str, int len) {
  $1 = gh_scm2newstr($input,&$2);
}

/* Return the mutated string as a new object.  */

%typemap(argout) (char *str, int len) {
  SWIG_APPEND_VALUE(gh_str2scm($1,$2));
  if ($1) scm_must_free($1);
}   

extern void capitalize(char *str, int len);

/* A multi-valued constraint.  Force two arguments to lie
   inside the unit circle */

%typemap(check) (double cx, double cy) {
   double a = $1*$1 + $2*$2;
   if (a > 1.0) {
	SWIG_exception(SWIG_ValueError,"$1_name and $2_name must be in unit circle");
   }
}

extern void circle(double cx, double cy);


