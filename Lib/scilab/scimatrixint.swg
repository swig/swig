/*
 * C-type: int array
 * Scilab type: 32-bit integer matrix
 */

%include <sciint.swg>

// (int* matrixAsInput, int rows, int cols)

%typemap(in, fragment="SWIG_SciInt32_AsIntArrayAndSize") (int* matrixAsInput, int rows, int cols)
{
  if (SWIG_SciInt32_AsIntArrayAndSize(pvApiCtx, $input, &$2, &$3, &$1, fname) == SWIG_ERROR)
  {
    return SWIG_ERROR;
  }
}


// (int rows, int cols, int* matrixAsInput)

%typemap(in, fragment="SWIG_SciInt32_AsIntArrayAndSize") (int rows, int cols, int* matrixAsInput)
{
  if (SWIG_SciInt32_AsIntArrayAndSize(pvApiCtx, $input, &$1, &$2, &$3, fname) == SWIG_ERROR)
  {
    return SWIG_ERROR;
  }
}


// (int* matrixAsInput, int size)

%typemap(in) (int* matrixAsInput, int size)
{
    int nbRows;
    int nbCols;
    if (SWIG_SciInt32_AsIntArrayAndSize(pvApiCtx, $input, &nbRows, &nbCols, &$1, fname) != SWIG_ERROR)
    {
        $2 = nbRows * nbCols;
    }
    else
    {
        return SWIG_ERROR;
    }
}


// (int size, int* matrixAsInput)

%typemap(in) (int size, int* matrixAsInput)
{
    int nbRows;
    int nbCols;
    if (SWIG_SciInt32_AsIntArrayAndSize(pvApiCtx, $input, &nbRows, &nbCols, &$2, fname) != SWIG_ERROR)
    {
        $1 = nbRows * nbCols;
    }
    else
    {
        return SWIG_ERROR;
    }
}

// (int** matrixAsOutput, int* rows, int* cols)

%typemap(in, numinputs=0) (int** matrixAsOutput, int* rows, int* cols)
{
}

%typemap(arginit) (int** matrixAsOutput, int* rows, int* cols)
{
  $1 = (int**) malloc(sizeof(int*));
  $2 = (int*) malloc(sizeof(int));
  $3 = (int*) malloc(sizeof(int));
}

%typemap(argout, fragment="SWIG_SciInt32_FromIntArrayAndSize") (int** matrixAsOutput, int* rows, int* cols)
{
  if (SWIG_SciInt32_FromIntArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), *$2, *$3, *$1) != SWIG_ERROR)
  {
    AssignOutputVariable(pvApiCtx, outputPosition) = nbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition();
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(freearg) (int** matrixAsOutput, int* rows, int* cols)
{
  free(*$1);
  free($1);
  free($2);
  free($3);
}


// (int* rows, int* cols, int** matrixAsOutput)

%typemap(in, numinputs=0) (int* rows, int* cols, int** matrixAsOutput)
{
}

%typemap(arginit) (int* rows, int* cols, int** matrixAsOutput)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (int*) malloc(sizeof(int));
  $3 = (int**) malloc(sizeof(int*));
}

%typemap(argout, fragment="SWIG_SciInt32_FromIntArrayAndSize") (int* rows, int* cols, int** matrixAsOutput)
{
  if (SWIG_SciInt32_FromIntArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), *$1, *$2, *$3) != SWIG_ERROR)
  {
    AssignOutputVariable(pvApiCtx, outputPosition) = nbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition();
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(freearg) (int* rows, int* cols, int** matrixAsOutput)
{
  free($1);
  free($2);
  free(*$3);
  free($3);
}


// (int** matrixAsOutput, int* size)

%typemap(in, numinputs=0) (int** matrixAsOutput, int* size)
{
}

%typemap(arginit) (int** matrixAsOutput, int* size)
{
  $1 = (int**) malloc(sizeof(int*));
  $2 = (int*) malloc(sizeof(int));
}

%typemap(argout, fragment="SWIG_SciInt32_FromIntArrayAndSize") (int** matrixAsOutput, int* size)
{

  if (SWIG_SciInt32_FromIntArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, *$2, *$1) != SWIG_ERROR)
  {
    AssignOutputVariable(pvApiCtx, outputPosition) = nbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition();
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(freearg) (int** matrixAsOutput, int* size)
{
  free(*$1);
  free($1);
  free($2);
}


// (int* size, int** matrixAsOutput)

%typemap(in, numinputs=0) (int* size, int** matrixAsOutput)
{
}

%typemap(arginit) (int* size, int** matrixAsOutput)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (int**) malloc(sizeof(int*));
}

%typemap(argout, fragment="SWIG_SciInt32_FromIntArrayAndSize") (int* size, int** matrixAsOutput)
{

  if (SWIG_SciInt32_FromIntArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, *$1, *$2) != SWIG_ERROR)
  {
    AssignOutputVariable(pvApiCtx, outputPosition) = nbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition();
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(freearg) (int* size, int** matrixAsOutput)
{
  free($1);
  free(*$2);
  free($2);
}

