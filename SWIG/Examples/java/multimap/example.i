/* File : example.i */
%module example
/*
%include exception.i
%include typemaps.i
*/

extern int    gcd(int x, int y);

%typemap(java,in) (int argc, char *argv[]) {
/* java in typemap int argc, char* argv[] */
}

extern int gcdmain(int argc, char *argv[]);

%typemap(java,in) (char *bytes, int len) {
/* java in typemap char *bytes, int len */
}

extern int count(char *bytes, int len, char c);


/* This example shows how to wrap a function that mutates a string */

/* Since str is modified, we make a copy of the Java object
   so that we don't violate it's mutability */

%typemap(java,in) (char *str, int len) {
/* java in typemap char* str, int len */
}

/* Return the mutated string as a new object.  The t_output_helper
   function takes an object and appends it to the output object
   to create a tuple */

%typemap(java,argout) (char *str, int len) {
/* java argout typemap char* str, int len */
}   

extern void capitalize(char *str, int len);

/* A multi-valued constraint.  Force two arguments to lie
   inside the unit circle */

%typemap(check) (double cx, double cy) {
/* check typemap double cx, double cy */
}

extern void circle(double cx, double cy);


