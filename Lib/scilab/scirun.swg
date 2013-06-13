/* Scilab function name management */
#include <stdlib.h>
static char* fname = NULL;
static char* SWIG_Scilab_GetFname(void) {
  return fname;
}
static void SWIG_Scilab_SetFname(char* _fname) {
  if (fname != NULL) {
    free(fname);
  }
  fname = strdup(_fname);
}
/* Scilab output argument management */
static int outputPosition = -1;
static int SWIG_Scilab_GetOutputPosition(void) {
  return outputPosition;
}
static int SWIG_Scilab_GetOutputPositionAndReset(void) {
  int returnValue = outputPosition;
  outputPosition = -1; /* Set as read */
  return returnValue;
}
static void SWIG_Scilab_SetOutputPosition(int _outputPosition) {
  outputPosition = _outputPosition;
}

#define Scilab_Error_Occurred() 0
#define SWIG_Scilab_AddErrorMsg(msg) {;}

