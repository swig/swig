/* File : example.i */
%module example
%include exception.i

extern int    gcd(int x, int y);

%typemap(tcl8,in) (int argc, char *argv[]) {
  Tcl_Obj **listobjv = 0;
  int i;
  if (Tcl_ListObjGetElements(interp,$arg, &$0, &listobjv) == TCL_ERROR) {
    SWIG_exception(SWIG_ValueError,"Expected a list");
    return TCL_ERROR;
  }
  $1 = (char **) malloc(($0+1)*sizeof(char *));
  for (i = 0; i < $0; i++) {
    $1[i] = Tcl_GetStringFromObj(listobjv[i],0);
  }
  $1[i] = 0;
}

%typemap(tcl8,freearg) char *argv[] {
  if ($0) {
    free($0);
  }
}

extern int gcdmain(int argc, char *argv[]);

%typemap(tcl8,in) (char *bytes, int len) {
  $0 = Tcl_GetStringFromObj($arg,&$1);
}

extern int count(char *bytes, int len, char c);


/* This example shows how to wrap a function that mutates a string */

%typemap(tcl8,in) (char *str, int len) {
  char *temp;
  temp = Tcl_GetStringFromObj($arg,&$1);
  $0 = (char *) malloc($1+1);
  memmove($0,temp,$1);
}

/* Return the mutated string as a new object.   */

%typemap(tcl8,argout) (char *str, int len) {
 Tcl_Obj *o;
 o = Tcl_NewStringObj($0,$1);
 Tcl_ListObjAppendElement(interp,$result,o);
 free($0);
}   

extern void capitalize(char *str, int len);


/* A multi-valued constraint.  Force two arguments to lie
   inside the unit circle */

%typemap(check) (double cx, double cy) {
   double a = $0*$0 + $1*$1;
   if (a > 1.0) {
	SWIG_exception(SWIG_ValueError,"$0_name and $1_name must be in unit circle");
        return NULL;
   }
}

extern void circle(double cx, double cy);
