/*
 * C-type: double array
 * Scilab type: double matrix
 */

%include <scidouble.swg>

// in (double* matrixIn, int matrixInRowCount, int matrixInColCount)

%typemap(in, fragment="SWIG_SciDouble_AsDoubleArrayAndSize") (double* matrixIn, int matrixInRowCount, int matrixInColCount)
{
  if (SWIG_SciDouble_AsDoubleArrayAndSize(pvApiCtx, $input, &$2, &$3, &$1, fname) != SWIG_OK)
  {
    return SWIG_ERROR;
  }
}

// in (int matrixInRowCount, int matrixInColCount, double* matrixIn)

%typemap(in, fragment="SWIG_SciDouble_AsDoubleArrayAndSize") (int matrixInRowCount, int matrixInColCount, double* matrixIn)
{
  if (SWIG_SciDouble_AsDoubleArrayAndSize(pvApiCtx, $input, &$1, &$2, &$3, fname) != SWIG_OK)
  {
    return SWIG_ERROR;
  }
}

// in (double* vectorIn, int vectorInSize)

%typemap(in, fragment="SWIG_SciDouble_AsDoubleArrayAndSize") (double* vectorIn, int vectorInSize)
{
    int rowCount;
    int colCount;
    if (SWIG_SciDouble_AsDoubleArrayAndSize(pvApiCtx, $input, &rowCount, &colCount, &$1, fname) == SWIG_OK)
    {
        $2 = rowCount * colCount;
    }
    else
    {
        return SWIG_ERROR;
    }
}

// in (int vectorInSize, double* vectorIn)

%typemap(in, fragment="SWIG_SciDouble_AsDoubleArrayAndSize") (int vectorInSize, double* vectorIn)
{
    int rowCount;
    int colCount;
    if (SWIG_SciDouble_AsDoubleArrayAndSize(pvApiCtx, $input, &rowCount, &colCount, &$2, fname) == SWIG_OK)
    {
        $1 = rowCount * colCount;
    }
    else
    {
        return SWIG_ERROR;
    }
}

// out (double** matrixOut, int* matrixOutRowCount, int* matrixOutColCount)

%typemap(in, numinputs=0) (double** matrixOut, int* matrixOutRowCount, int* matrixOutColCount)
{
}

%typemap(arginit) (double** matrixOut, int* matrixOutRowCount, int* matrixOutColCount)
{
  $1 = (double**) malloc(sizeof(double*));
  $2 = (int*) malloc(sizeof(int));
  $3 = (int*) malloc(sizeof(int));
}

%typemap(freearg) (double** matrixOut, int* matrixOutRowCount, int* matrixOutColCount)
{
  free(*$1);
  free($1);
  free($2);
  free($3);
}

%typemap(argout, fragment="SWIG_SciDouble_FromDoubleArrayAndSize") (double** matrixOut, int* matrixOutRowCount, int* matrixOutColCount)
{
  if (SWIG_SciDouble_FromDoubleArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), *$2, *$3, *$1) == SWIG_OK)
  {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else
  {
    return SWIG_ERROR;
  }
}

// out (int* matrixOutRowCount, int* matrixOutColCount, double** matrixOut)

%typemap(in, numinputs=0) (int* matrixOutRowCount, int* matrixOutColCount, double** matrixOut)
{
}

%typemap(arginit) (int* matrixOutRowCount, int* matrixOutColCount, double** matrixOut)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (int*) malloc(sizeof(int));
  $3 = (double**) malloc(sizeof(double*));
}

%typemap(argout, fragment="SWIG_SciDouble_FromDoubleArrayAndSize") (int* matrixInRowCount, int* matrixInColCount, double** matrixOut)
{
  if (SWIG_SciDouble_FromDoubleArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), *$1, *$2, *$3) == SWIG_OK)
  {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(freearg) (int* matrixOutRowCount, int* matrixOutColCount, double** matrixOut)
{
  free($1);
  free($2);
  free(*$3);
  free($3);
}


// out (double** vectorOut, int* vectorOutSize)

%typemap(in, numinputs=0) (double** vectorOut, int* vectorOutSize)
{
}

%typemap(arginit) (double** vectorOut, int* vectorOutSize)
{
  $1 = (double**) malloc(sizeof(double*));
  $2 = (int*) malloc(sizeof(int));
}

%typemap(argout, fragment="SWIG_SciDouble_FromDoubleArrayAndSize") (double** vectorOut, int* vectorOutSize)
{
  if (SWIG_SciDouble_FromDoubleArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, *$2, *$1) == SWIG_OK)
  {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(freearg) (double** vectorOut, int* vectorOutSize)
{
  free(*$1);
  free($1);
  free($2);
}


// out (int* vectorOutSize, double** vectorOut)

%typemap(in, numinputs=0) (int* vectorOutSize, double** vectorOut)
{
}

%typemap(arginit) (int* vectorOutSize, double** vectorOut)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (double**) malloc(sizeof(double*));
}

%typemap(argout, fragment="SWIG_SciDouble_FromDoubleArrayAndSize") (int* vectorOutSize, double** vectorOut)
{
  if (SWIG_SciDouble_FromDoubleArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, *$1, *$2) == SWIG_OK)
  {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(freearg) (int* vectorOutSize, double** vectorOut)
{
  free($1);
  free(*$2);
  free($2);
}
