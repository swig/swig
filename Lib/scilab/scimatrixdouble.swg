/*
 * C-type: double array
 * Scilab type: double matrix
 */

%include <scidouble.swg>

// in (double *matrixIn, int matrixInRowCount, int matrixInColCount)

%typemap(in, noblock=1, fragment="SWIG_SciDouble_AsDoubleArrayAndSize") (double *matrixIn, int matrixInRowCount, int matrixInColCount)
{
  if (SWIG_SciDouble_AsDoubleArrayAndSize(pvApiCtx, $input, &$2, &$3, &$1, fname) != SWIG_OK)
  {
    return SWIG_ERROR;
  }
}

// in (int matrixInRowCount, int matrixInColCount, double *matrixIn)

%typemap(in, noblock=1, fragment="SWIG_SciDouble_AsDoubleArrayAndSize") (int matrixInRowCount, int matrixInColCount, double *matrixIn)
{
  if (SWIG_SciDouble_AsDoubleArrayAndSize(pvApiCtx, $input, &$1, &$2, &$3, fname) != SWIG_OK)
  {
    return SWIG_ERROR;
  }
}

// in (double *matrixIn, int matrixInSize)

%typemap(in, noblock=1, fragment="SWIG_SciDouble_AsDoubleArrayAndSize") (double *matrixIn, int matrixInSize)
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

// in (int matrixInSize, double *matrixIn)

%typemap(in, noblock=1, fragment="SWIG_SciDouble_AsDoubleArrayAndSize") (int matrixInSize, double *matrixIn)
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

// out (double **matrixOut, int *matrixOutRowCount, int *matrixOutColCount)

%typemap(in, noblock=1, numinputs=0) (double **matrixOut, int *matrixOutRowCount, int *matrixOutColCount)
{
}

%typemap(arginit, noblock=1) (double **matrixOut, int *matrixOutRowCount, int *matrixOutColCount)
{
  $1 = (double**) malloc(sizeof(double*));
  $2 = (int*) malloc(sizeof(int));
  $3 = (int*) malloc(sizeof(int));
}

%typemap(freearg, noblock=1) (double **matrixOut, int *matrixOutRowCount, int *matrixOutColCount)
{
  free(*$1);
  free($1);
  free($2);
  free($3);
}

%typemap(argout, noblock=1, fragment="SWIG_SciDouble_FromDoubleArrayAndSize") (double **matrixOut, int *matrixOutRowCount, int *matrixOutColCount)
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

// out (int *matrixOutRowCount, int *matrixOutColCount, double **matrixOut)

%typemap(in, noblock=1, numinputs=0) (int *matrixOutRowCount, int *matrixOutColCount, double **matrixOut)
{
}

%typemap(arginit, noblock=1) (int *matrixOutRowCount, int *matrixOutColCount, double **matrixOut)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (int*) malloc(sizeof(int));
  $3 = (double**) malloc(sizeof(double*));
}

%typemap(argout, noblock=1, fragment="SWIG_SciDouble_FromDoubleArrayAndSize") (int *matrixInRowCount, int *matrixInColCount, double **matrixOut)
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

%typemap(freearg, noblock=1) (int *matrixOutRowCount, int *matrixOutColCount, double **matrixOut)
{
  free($1);
  free($2);
  free(*$3);
  free($3);
}


// out (double **matrixOut, int *matrixOutSize)

%typemap(in, noblock=1, numinputs=0) (double **matrixOut, int *matrixOutSize)
{
}

%typemap(arginit, noblock=1) (double **matrixOut, int *matrixOutSize)
{
  $1 = (double**) malloc(sizeof(double*));
  $2 = (int*) malloc(sizeof(int));
}

%typemap(argout, noblock=1, fragment="SWIG_SciDouble_FromDoubleArrayAndSize") (double **matrixOut, int *matrixOutSize)
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

%typemap(freearg, noblock=1) (double **matrixOut, int *matrixOutSize)
{
  free(*$1);
  free($1);
  free($2);
}


// out (int *matrixOutSize, double **matrixOut)

%typemap(in, noblock=1, numinputs=0) (int *matrixOutSize, double **matrixOut)
{
}

%typemap(arginit, noblock=1) (int *matrixOutSize, double **matrixOut)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (double**) malloc(sizeof(double*));
}

%typemap(argout, noblock=1, fragment="SWIG_SciDouble_FromDoubleArrayAndSize") (int *matrixOutSize, double **matrixOut)
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

%typemap(freearg, noblock=1) (int *matrixOutSize, double **matrixOut)
{
  free($1);
  free(*$2);
  free($2);
}
