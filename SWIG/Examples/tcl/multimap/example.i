/* File : example.i */
%module example
%include exception.i

extern int    gcd(int x, int y);

%typemap(tcl8,in) (int argc, char *argv[]) {
  Tcl_Obj **listobjv = 0;
  int i;
  if (Tcl_ListObjGetElements(interp,$source, &$0, &listobjv) == TCL_ERROR) {
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
  if ($source) {
    free($source);
  }
}

extern int gcdmain(int argc, char *argv[]);

%typemap(tcl8,in) (char *bytes, int len) {
  $0 = Tcl_GetStringFromObj($source,&$1);
}

extern int count(char *bytes, int len, char c);

