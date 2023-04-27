%module check_typemap

%include exception.i
%include typemaps.i

%typemap(check) (double x, double y) {
   double a = $1*$1 + $2*$2;
   if (a > 1.0) {
     SWIG_exception_fail(SWIG_ValueError,"$1_name and $2_name must be in unit circle");
   }
}

%inline %{

void circle(double x, double y) {
  double a = x*x + y*y;
  if (a > 1.0) {
    printf("Bad points %g, %g\n", x,y);
  } else {
    printf("Good points %g, %g\n", x,y);
  }
}

%}

