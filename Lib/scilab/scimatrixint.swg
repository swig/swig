/*
 * C-type: int array
 * Scilab type: 32-bit integer matrix
 */

%include <sciint.swg>

// in (int *matrixIn, int matrixInRowCount, int matrixInColCount)

%typemap(in, noblock=1, fragment="SWIG_SciDoubleOrInt32_AsIntArrayAndSize") (int *matrixIn, int matrixInRowCount, int matrixInColCount)
{
  if (SWIG_SciDoubleOrInt32_AsIntArrayAndSize(pvApiCtx, $input, &$2, &$3, &$1, fname) != SWIG_OK)
  {
    return SWIG_ERROR;
  }
}


// in (int matrixInRowCount, int matrixInColCount, int *matrixIn)

%typemap(in, noblock=1, fragment="SWIG_SciDoubleOrInt32_AsIntArrayAndSize") (int matrixInRowCount, int matrixInColCount, int *matrixIn)
{
  if (SWIG_SciDoubleOrInt32_AsIntArrayAndSize(pvApiCtx, $input, &$1, &$2, &$3, fname) != SWIG_OK)
  {
    return SWIG_ERROR;
  }
}


// in (int *matrixIn, int matrixInSize)

%typemap(in, noblock=1, fragment="SWIG_SciDoubleOrInt32_AsIntArrayAndSize") (int *matrixIn, int matrixInSize)
{
    int rowCount;
    int colCount;
    if (SWIG_SciDoubleOrInt32_AsIntArrayAndSize(pvApiCtx, $input, &rowCount, &colCount, &$1, fname) == SWIG_OK)
    {
        $2 = rowCount * colCount;
    }
    else
    {
        return SWIG_ERROR;
    }
}


// in (int matrixInSize, int *matrixIn)

%typemap(in, noblock=1, fragment="SWIG_SciDoubleOrInt32_AsIntArrayAndSize") (int matrixInSize, int *matrixIn)
{
    int rowCount;
    int colCount;
    if (SWIG_SciDoubleOrInt32_AsIntArrayAndSize(pvApiCtx, $input, &rowCount, &colCount, &$2, fname) == SWIG_OK)
    {
        $1 = rowCount * colCount;
    }
    else
    {
        return SWIG_ERROR;
    }
}

// out (int **matrixOut, int *matrixOutRowCount, int *matrixOutColCount)

%typemap(in, noblock=1, numinputs=0) (int **matrixOut, int *matrixOutRowCount, int *matrixOutColCount)
{
}

%typemap(arginit, noblock=1) (int **matrixOut, int *matrixOutRowCount, int *matrixOutColCount)
{
  $1 = (int**) malloc(sizeof(int*));
  $2 = (int*) malloc(sizeof(int));
  $3 = (int*) malloc(sizeof(int));
}

%typemap(argout, noblock=1, fragment="SWIG_SciDouble_FromIntArrayAndSize") (int **matrixOut, int *matrixOutRowCount, int *matrixOutColCount)
{
  if (SWIG_SciDouble_FromIntArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), *$2, *$3, *$1) == SWIG_OK)
  {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(freearg, noblock=1) (int **matrixOut, int *matrixOutRowCount, int *matrixOutColCount)
{
  free(*$1);
  free($1);
  free($2);
  free($3);
}


// out (int *matrixOutRowCount, int *matrixOutColCount, int **matrixOut)

%typemap(in, noblock=1, numinputs=0) (int *matrixOutRowCount, int *matrixOutColCount, int **matrixOut)
{
}

%typemap(arginit, noblock=1) (int *matrixOutRowCount, int *matrixOutColCount, int **matrixOut)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (int*) malloc(sizeof(int));
  $3 = (int**) malloc(sizeof(int*));
}

%typemap(argout, noblock=1, fragment="SWIG_SciDouble_FromIntArrayAndSize") (int *matrixOutRowCount, int *matrixOutColCount, int **matrixOut)
{
  if (SWIG_SciDouble_FromIntArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), *$1, *$2, *$3) == SWIG_OK)
  {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(freearg, noblock=1) (int *matrixOutRowCount, int *matrixOutColCount, int **matrixOut)
{
  free($1);
  free($2);
  free(*$3);
  free($3);
}


// out (int **matrixOut, int *matrixOutSize)

%typemap(in, noblock=1, numinputs=0) (int **matrixOut, int *matrixOutSize)
{
}

%typemap(arginit) (int **matrixOut, int *matrixOutSize)
{
  $1 = (int**) malloc(sizeof(int*));
  $2 = (int*) malloc(sizeof(int));
}

%typemap(argout, noblock=1, fragment="SWIG_SciDouble_FromIntArrayAndSize") (int **matrixOut, int *matrixOutSize)
{
  if (SWIG_SciDouble_FromIntArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, *$2, *$1) == SWIG_OK)
  {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(freearg, noblock=1) (int **matrixOut, int *matrixOutSize)
{
  free(*$1);
  free($1);
  free($2);
}


// out (int *matrixOutSize, int **matrixOut)

%typemap(in, noblock=1, numinputs=0) (int *matrixOutSize, int **matrixOut)
{
}

%typemap(arginit, noblock=1) (int *matrixOutSize, int **matrixOut)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (int**) malloc(sizeof(int*));
}

%typemap(argout, noblock=1, fragment="SWIG_SciDouble_FromIntArrayAndSize") (int *matrixOutSize, int **matrixOut)
{
  if (SWIG_SciDouble_FromIntArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, *$1, *$2) == SWIG_OK)
  {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(freearg, noblock=1) (int *matrixInSize, int **matrixOut)
{
  free($1);
  free(*$2);
  free($2);
}

