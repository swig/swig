#include <tcl.h>
extern int matrix_init(Tcl_Interp *);    /* Init function from matrix.i */

int main() {

  int        code;
  char       input[1024];
  Tcl_Interp *interp;
  
  interp = Tcl_CreateInterp();

  /* Initialize the wrappers */

  if (matrix_init(interp) == TCL_ERROR)
    exit(0);
  
  fprintf(stdout,"matrix > ");
  while(fgets(input, 1024, stdin) != NULL) {
    code = Tcl_Eval(interp, input);
    fprintf(stdout,"%s\n",interp->result);
    fprintf(stdout,"matrix > ");
  }
}

