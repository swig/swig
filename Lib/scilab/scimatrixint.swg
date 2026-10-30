/*
 * C-type: int array
 * Scilab type: 32-bit integer matrix
 */

%include <sciint.swg>

// in (int *IN, int IN_ROWCOUNT, int IN_COLCOUNT)

%typemap(in, noblock=1, fragment="SWIG_SciDoubleOrInt32_AsIntArrayAndSize") (int *IN, int IN_ROWCOUNT, int IN_COLCOUNT) (int iAllocated=0)
{
  if (SWIG_SciDoubleOrInt32_AsIntArrayAndSize(pvApiCtx, $input, &$2, &$3, &$1, &iAllocated, fname) != SWIG_OK) {
    SWIG_fail;
  }
}
%typemap(freearg, noblock=1) (int *IN, int IN_ROWCOUNT, int IN_COLCOUNT)
{
  if (iAllocated$argnum) free($1);
}


// in (int IN_ROWCOUNT, int IN_COLCOUNT, int *IN)

%typemap(in, noblock=1, fragment="SWIG_SciDoubleOrInt32_AsIntArrayAndSize") (int IN_ROWCOUNT, int IN_COLCOUNT, int *IN) (int iAllocated=0)
{
  if (SWIG_SciDoubleOrInt32_AsIntArrayAndSize(pvApiCtx, $input, &$1, &$2, &$3, &iAllocated, fname) != SWIG_OK) {
    SWIG_fail;
  }
}
%typemap(freearg, noblock=1) (int IN_ROWCOUNT, int IN_COLCOUNT, int *IN)
{
  if (iAllocated$argnum) free($3);
}


// in (int *IN, int IN_SIZE)

%typemap(in, noblock=1, fragment="SWIG_SciDoubleOrInt32_AsIntArrayAndSize") (int *IN, int IN_SIZE) (int rowCount=0, int colCount=0, int iAllocated=0)
{
  if (SWIG_SciDoubleOrInt32_AsIntArrayAndSize(pvApiCtx, $input, &rowCount, &colCount, &$1, &iAllocated, fname) == SWIG_OK) {
    if (rowCount < 0) {
      $2 = rowCount;
    } else {
      $2 = rowCount * colCount;
    }
  }
  else {
    SWIG_fail;
  }
}
%typemap(freearg, noblock=1) (int *IN, int IN_SIZE)
{
  if (iAllocated$argnum) free($1);
}


// in (int IN_SIZE, int *IN)

%typemap(in, noblock=1, fragment="SWIG_SciDoubleOrInt32_AsIntArrayAndSize") (int IN_SIZE, int *IN) (int rowCount=0, int colCount=0, int iAllocated=0)
{
  if (SWIG_SciDoubleOrInt32_AsIntArrayAndSize(pvApiCtx, $input, &rowCount, &colCount, &$2, &iAllocated, fname) == SWIG_OK) {
    if (rowCount < 0) {
      $1 = rowCount;
    } else {
      $1 = rowCount * colCount;
    }
  }
  else {
    SWIG_fail;
  }
}
%typemap(freearg, noblock=1) (int IN_SIZE, int *IN)
{
  if (iAllocated$argnum) free($2);
}

// out (int **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT)

%typemap(in, noblock=1, numinputs=0) (int **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT)
{
}

%typemap(arginit, noblock=1) (int **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT)
{
  $1 = (int**) malloc(sizeof(int*));
  *$1 = NULL;
  $2 = (int*) malloc(sizeof(int));
  $3 = (int*) malloc(sizeof(int));
}

%typemap(argout, noblock=1, fragment="SWIG_SciDouble_FromIntArrayAndSize") (int **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT)
{
  if (SWIG_SciDouble_FromIntArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), *$2, *$3, *$1) == SWIG_OK) {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else {
    SWIG_fail;
  }
}

%typemap(freearg, noblock=1) (int **OUT, int *OUT_ROWCOUNT, int *OUT_COLCOUNT)
{
  free(*$1);
  free($1);
  free($2);
  free($3);
}


// out (int *OUT_ROWCOUNT, int *OUT_COLCOUNT, int **OUT)

%typemap(in, noblock=1, numinputs=0) (int *OUT_ROWCOUNT, int *OUT_COLCOUNT, int **OUT)
{
}

%typemap(arginit, noblock=1) (int *OUT_ROWCOUNT, int *OUT_COLCOUNT, int **OUT)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (int*) malloc(sizeof(int));
  $3 = (int**) malloc(sizeof(int*));
  *$3 = NULL;
}

%typemap(argout, noblock=1, fragment="SWIG_SciDouble_FromIntArrayAndSize") (int *OUT_ROWCOUNT, int *OUT_COLCOUNT, int **OUT)
{
  if (SWIG_SciDouble_FromIntArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), *$1, *$2, *$3) == SWIG_OK) {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else {
    SWIG_fail;
  }
}

%typemap(freearg, noblock=1) (int *OUT_ROWCOUNT, int *OUT_COLCOUNT, int **OUT)
{
  free($1);
  free($2);
  free(*$3);
  free($3);
}


// out (int **OUT, int *OUT_SIZE)

%typemap(in, noblock=1, numinputs=0) (int **OUT, int *OUT_SIZE)
{
}

%typemap(arginit) (int **OUT, int *OUT_SIZE)
{
  $1 = (int**) malloc(sizeof(int*));
  *$1 = NULL;
  $2 = (int*) malloc(sizeof(int));
}

%typemap(argout, noblock=1, fragment="SWIG_SciDouble_FromIntArrayAndSize") (int **OUT, int *OUT_SIZE)
{
  if (SWIG_SciDouble_FromIntArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, *$2, *$1) == SWIG_OK) {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else {
    SWIG_fail;
  }
}

%typemap(freearg, noblock=1) (int **OUT, int *OUT_SIZE)
{
  free(*$1);
  free($1);
  free($2);
}


// out (int *OUT_SIZE, int **OUT)

%typemap(in, noblock=1, numinputs=0) (int *OUT_SIZE, int **OUT)
{
}

%typemap(arginit, noblock=1) (int *OUT_SIZE, int **OUT)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (int**) malloc(sizeof(int*));
  *$2 = NULL;
}

%typemap(argout, noblock=1, fragment="SWIG_SciDouble_FromIntArrayAndSize") (int *OUT_SIZE, int **OUT)
{
  if (SWIG_SciDouble_FromIntArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, *$1, *$2) == SWIG_OK) {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else {
    SWIG_fail;
  }
}

%typemap(freearg, noblock=1) (int *IN_SIZE, int **OUT)
{
  free($1);
  free(*$2);
  free($2);
}

