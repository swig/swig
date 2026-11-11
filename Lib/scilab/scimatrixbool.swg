/*
 * C-type: bool array
 * Scilab type: bool matrix
 */

%include <scibool.swg>

// in (bool *IN, int IN_ROWCOUNT, int IN_COLCOUNT)

%typemap(in, noblock=1, fragment="SWIG_SciBoolean_AsBoolArrayAndSize") (bool *IN, int IN_ROWCOUNT, int IN_COLCOUNT) (int iAllocated=0)
{
  if (SWIG_SciBoolean_AsBoolArrayAndSize(pvApiCtx, $input, &$2, &$3, &$1, &iAllocated, fname) != SWIG_OK) {
    SWIG_fail;
  }
}
%typemap(freearg, noblock=1) (bool *IN, int IN_ROWCOUNT, int IN_COLCOUNT)
{
  if (iAllocated$argnum) free($1);
}

// in (int IN_ROWCOUNT, int IN_COLCOUNT, bool *IN)

%typemap(in, noblock=1, fragment="SWIG_SciBoolean_AsBoolArrayAndSize") (int IN_ROWCOUNT, int IN_COLCOUNT, bool *IN) (int iAllocated=0)
{
  if (SWIG_SciBoolean_AsBoolArrayAndSize(pvApiCtx, $input, &$1, &$2, &$3, &iAllocated, fname) != SWIG_OK) {
    SWIG_fail;
  }
}
%typemap(freearg, noblock=1) (int IN_ROWCOUNT, int IN_COLCOUNT, bool *IN)
{
  if (iAllocated$argnum) free($3);
}

// in (bool *IN, int IN_SIZE)

%typemap(in, noblock=1, fragment="SWIG_SciBoolean_AsBoolArrayAndSize") (bool *IN, int IN_SIZE) (int rowCount=0, int colCount=0, int iAllocated=0)
{
  if (SWIG_SciBoolean_AsBoolArrayAndSize(pvApiCtx, $input, &rowCount, &colCount, &$1, &iAllocated, fname) == SWIG_OK) {
    $2 = rowCount * colCount;
  }
  else {
    SWIG_fail;
  }
}
%typemap(freearg, noblock=1) (bool *IN, int IN_SIZE)
{
  if (iAllocated$argnum) free($1);
}

// in (int IN_SIZE, bool *IN)

%typemap(in, noblock=1, fragment="SWIG_SciBoolean_AsBoolArrayAndSize") (int IN_SIZE, bool *IN) (int rowCount=0, int colCount=0, int iAllocated=0)
{
  if (SWIG_SciBoolean_AsBoolArrayAndSize(pvApiCtx, $input, &rowCount, &colCount, &$2, &iAllocated, fname) == SWIG_OK) {
    $1 = rowCount * colCount;
  }
  else {
    SWIG_fail;
  }
}
%typemap(freearg, noblock=1) (int IN_SIZE, bool *IN)
{
  if (iAllocated$argnum) free($2);
}

// out (bool **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT)

%typemap(in, noblock=1, numinputs=0) (bool **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT)
{
}

%typemap(arginit, noblock=1) (bool **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT)
{
  $1 = (bool**) malloc(sizeof(bool*));
  *$1 = NULL;
  $2 = (int*) malloc(sizeof(int));
  $3 = (int*) malloc(sizeof(int));
}

%typemap(freearg, noblock=1) (bool **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT)
{
  free(*$1);
  free($1);
  free($2);
  free($3);
}

%typemap(argout, noblock=1, fragment="SWIG_SciBoolean_FromBoolArrayAndSize") (bool **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT)
{
  if (SWIG_SciBoolean_FromBoolArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), *$2, *$3, *$1) == SWIG_OK) {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else {
    SWIG_fail;
  }
}

// out (int *OUT_ROWCOUNT, int *OUT_COLCOUNT, bool **OUT)

%typemap(in, noblock=1, numinputs=0) (int *OUT_ROWCOUNT, int *OUT_COLCOUNT, bool **OUT)
{
}

%typemap(arginit, noblock=1) (int *OUT_ROWCOUNT, int *OUT_COLCOUNT, bool **OUT)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (int*) malloc(sizeof(int));
  $3 = (bool**) malloc(sizeof(bool*));
  *$3 = NULL;
}

%typemap(argout, noblock=1, fragment="SWIG_SciBoolean_FromBoolArrayAndSize") (int *OUT_ROWCOUNT, int *OUT_COLCOUNT, bool **OUT)
{
  if (SWIG_SciBoolean_FromBoolArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), *$1, *$2, *$3) == SWIG_OK) {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else {
    SWIG_fail;
  }
}

%typemap(freearg, noblock=1) (int *OUT_ROWCOUNT, int *OUT_COLCOUNT, bool **OUT)
{
  free($1);
  free($2);
  free(*$3);
  free($3);
}


// out (bool **OUT, int *OUT_SIZE)

%typemap(in, noblock=1, numinputs=0) (bool **OUT, int *OUT_SIZE)
{
}

%typemap(arginit, noblock=1) (bool **OUT, int *OUT_SIZE)
{
  $1 = (bool**) malloc(sizeof(bool*));
  *$1 = NULL;
  $2 = (int*) malloc(sizeof(int));
}

%typemap(argout, noblock=1, fragment="SWIG_SciBoolean_FromBoolArrayAndSize") (bool **OUT, int *OUT_SIZE)
{
  if (SWIG_SciBoolean_FromBoolArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, *$2, *$1) == SWIG_OK) {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else {
    SWIG_fail;
  }
}

%typemap(freearg, noblock=1) (bool **OUT, int *OUT_SIZE)
{
  free(*$1);
  free($1);
  free($2);
}


// out (int *OUT_SIZE, bool **OUT)

%typemap(in, noblock=1, numinputs=0) (int *OUT_SIZE, bool **OUT)
{
}

%typemap(arginit, noblock=1) (int *OUT_SIZE, bool **OUT)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (bool**) malloc(sizeof(bool*));
  *$2 = NULL;
}

%typemap(argout, noblock=1, fragment="SWIG_SciBoolean_FromBoolArrayAndSize") (int *OUT_SIZE, bool **OUT)
{
  if (SWIG_SciBoolean_FromBoolArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, *$1, *$2) == SWIG_OK) {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else {
    SWIG_fail;
  }
}

%typemap(freearg, noblock=1) (int *OUT_SIZE, bool **OUT)
{
  free($1);
  free(*$2);
  free($2);
}
