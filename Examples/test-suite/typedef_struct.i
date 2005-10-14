%module typedef_struct

%inline {
  typedef struct {
    int numpoints;
  } lineObj;
  
  typedef lineObj multipointObj;
}
