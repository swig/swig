/* This interface file checks how well SWIG handles passing data back
   through arguments WITHOUT returnin it seperatly; for the cases where
   maybe multiple values are passed by refernce and all want changing */

%module argout

%include cpointer.i
%pointer_functions(int,intp);

%inline %{
// returns old value
int incp(int *value) {
  return (*value)++;
}

// returns old value
int incr(int &value) {
  return value++;
}

%}
