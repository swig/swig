/* File : example.i */
%module example
%include exception.i
%include typemaps.i

extern int    gcd(int x, int y);

%typemap(perl5,in) (int argc, char *argv[]) {
  AV *tempav;
  SV **tv;
  I32 len;
  int i;
  if (!SvROK($arg)) {
    SWIG_exception(SWIG_ValueError,"$arg is not an array.");
  }
  if (SvTYPE(SvRV($arg)) != SVt_PVAV) {
    SWIG_exception(SWIG_ValueError,"$arg is not an array.");
  }
  tempav = (AV*)SvRV($arg);
  len = av_len(tempav);
  $0 = (int) len+1;
  $1 = (char **) malloc($0*sizeof(char *));
  for (i = 0; i < $0; i++) {
    tv = av_fetch(tempav, i, 0);
    $1[i] = (char *) SvPV(*tv,PL_na);
  }
  $1[i] = 0;
}

%typemap(perl5,freearg) (int argc, char *argv[]) {
  free($1);
}

extern int gcdmain(int argc, char *argv[]);

%typemap(perl5,in) (char *bytes, int len) {
  $0 = (char *) SvPV($arg,$1);
}

extern int count(char *bytes, int len, char c);


/* This example shows how to wrap a function that mutates a string */

%typemap(perl5,in) (char *str, int len) {
  char *temp;
  temp = (char *) SvPV($arg,$1);
  $0 = (char *) malloc($1+1);
  memmove($0,temp,$1);
}

/* Return the mutated string as a new object.  */

%typemap(perl5,argout) (char *str, int len) {
  if (argvi >= items) {
    EXTEND(sp,1);
  }
  $result = sv_newmortal();
  sv_setpvn((SV*)ST(argvi++),$0,$1);
  free($0);
}   

extern void capitalize(char *str, int len);

/* A multi-valued constraint.  Force two arguments to lie
   inside the unit circle */

%typemap(check) (double cx, double cy) {
   double a = $0*$0 + $1*$1;
   if (a > 1.0) {
	SWIG_exception(SWIG_ValueError,"$0_name and $1_name must be in unit circle");
   }
}

extern void circle(double cx, double cy);


