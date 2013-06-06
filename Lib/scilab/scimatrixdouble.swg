/*
 * C-type: double array
 * Scilab type: double matrix
 */

%include <scidouble.swg>

%typemap(in, fragment="SWIG_SciDouble_AsDoubleArrayAndSize") (double* matrixAsInput, int rows, int cols)
{
  if (SWIG_SciDouble_AsDoubleArrayAndSize(pvApiCtx, $input, &$2, &$3, &$1, fname) == SWIG_ERROR)
  {
    return SWIG_ERROR;
  }
}

%typemap(in, fragment="SWIG_SciDouble_AsDoubleArrayAndSize") (int rows, int cols, double* matrixAsInput)
{
  if (SWIG_SciDouble_AsDoubleArrayAndSize(pvApiCtx, $input, &$1, &$2, &$3, fname) == SWIG_ERROR)
  {
    return SWIG_ERROR;
  }
}

%typemap(in) (double* matrixAsInput, int size)
{
    int nbRows;
    int nbCols;
    if (SWIG_SciDouble_AsDoubleArrayAndSize(pvApiCtx, $input, &nbRows, &nbCols, &$1, fname) != SWIG_ERROR)
    {
        $2 = nbRows * nbCols;
    }
    else
    {
        return SWIG_ERROR;
    }
}

%typemap(in) (int size, double* matrixAsInput)
{
    int nbRows;
    int nbCols;
    if (SWIG_SciDouble_AsDoubleArrayAndSize(pvApiCtx, $input, &nbRows, &nbCols, &$2, fname) != SWIG_ERROR)
    {
        $1 = nbRows * nbCols;
    }
    else
    {
        return SWIG_ERROR;
    }
}

%typemap(in, numinputs=0) (double** matrixAsOutput, int* rows, int* cols)
{
}

%typemap(arginit) (double** matrixAsOutput, int* rows, int* cols)
{
  $1 = (double**) malloc(sizeof(double*));
  $2 = (int*) malloc(sizeof(int));
  $3 = (int*) malloc(sizeof(int));
}

%typemap(freearg) (double** matrixAsOutput, int* rows, int* cols)
{
  free(*$1);
  free($1);
  free($2);
  free($3);
}

%typemap(argout, fragment="SWIG_SciDouble_FromDoubleArrayAndSize") (double** matrixAsOutput, int* rows, int* cols)
{
  if (SWIG_SciDouble_FromDoubleArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), *$2, *$3, *$1) != SWIG_ERROR)
  {
    AssignOutputVariable(pvApiCtx, outputPosition) = nbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition();
  }
  else
  {
    return SWIG_ERROR;
  }
}

// (int* rows, int* cols, double** matrixAsOutput)

%typemap(in, numinputs=0) (int* rows, int* cols, double** matrixAsOutput)
{
}

%typemap(arginit) (int* rows, int* cols, double** matrixAsOutput)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (int*) malloc(sizeof(int));
  $3 = (double**) malloc(sizeof(double*));
}

%typemap(argout, fragment="SWIG_SciInt32_FromIntArrayAndSize") (int* rows, int* cols, double** matrixAsOutput)
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

%typemap(freearg) (int* rows, int* cols, double** matrixAsOutput)
{
  free($1);
  free($2);
  free(*$3);
  free($3);
}


// (double** matrixAsOutput, int* size)

%typemap(in, numinputs=0) (double** matrixAsOutput, int* size)
{
}

%typemap(arginit) (double** matrixAsOutput, int* size)
{
  $1 = (double**) malloc(sizeof(double*));
  $2 = (int*) malloc(sizeof(int));
}

%typemap(argout, fragment="SWIG_SciInt32_FromIntArrayAndSize") (double** matrixAsOutput, int* size)
{

  if (SWIG_SciDouble_FromDoubleArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, *$2, *$1) != SWIG_ERROR)
  {
    AssignOutputVariable(pvApiCtx, outputPosition) = nbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition();
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(freearg) (double** matrixAsOutput, int* size)
{
  free(*$1);
  free($1);
  free($2);
}


// (int* size, double** matrixAsOutput)

%typemap(in, numinputs=0) (int* size, double** matrixAsOutput)
{
}

%typemap(arginit) (int* size, double** matrixAsOutput)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (double**) malloc(sizeof(double*));
}

%typemap(argout, fragment="SWIG_SciInt32_FromIntArrayAndSize") (int* size, double** matrixAsOutput)
{

  if (SWIG_SciDouble_FromDoubleArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, *$1, *$2) != SWIG_ERROR)
  {
    AssignOutputVariable(pvApiCtx, outputPosition) = nbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition();
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(freearg) (int* size, double** matrixAsOutput)
{
  free($1);
  free(*$2);
  free($2);
}
