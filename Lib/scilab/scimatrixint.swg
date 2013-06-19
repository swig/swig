/*
 * C-type: int array
 * Scilab type: 32-bit integer matrix
 */

%include <sciint.swg>

// in (int* matrixIn, int matrixInRowCount, int matrixInColCount)

%typemap(in, fragment="SWIG_SciInt32_AsIntArrayAndSize") (int* matrixIn, int matrixInRowCount, int matrixInColCount)
{
  if (SWIG_SciInt32_AsIntArrayAndSize(pvApiCtx, $input, &$2, &$3, &$1, fname) == SWIG_ERROR)
  {
    return SWIG_ERROR;
  }
}


// in (int matrixInRowCount, int matrixInColCount, int* matrixIn)

%typemap(in, fragment="SWIG_SciInt32_AsIntArrayAndSize") (int matrixInRowCount, int matrixInColCount, int* matrixIn)
{
  if (SWIG_SciInt32_AsIntArrayAndSize(pvApiCtx, $input, &$1, &$2, &$3, fname) == SWIG_ERROR)
  {
    return SWIG_ERROR;
  }
}


// in (int* vectorIn, int vectorInSize)

%typemap(in) (int* vectorIn, int vectorInSize)
{
    int rowCount;
    int colCount;
    if (SWIG_SciInt32_AsIntArrayAndSize(pvApiCtx, $input, &rowCount, &colCount, &$1, fname) != SWIG_ERROR)
    {
        $2 = rowCount * colCount;
    }
    else
    {
        return SWIG_ERROR;
    }
}


// in (int vectorInSize, int* vectorInSize)

%typemap(in) (int vectorInSize, int* vectorInSize)
{
    int rowCount;
    int colCount;
    if (SWIG_SciInt32_AsIntArrayAndSize(pvApiCtx, $input, &rowCount, &colCount, &$2, fname) != SWIG_ERROR)
    {
        $1 = rowCount * colCount;
    }
    else
    {
        return SWIG_ERROR;
    }
}

// out (int** matrixOut, int* matrixOutRowCount, int* matrixOutColCount)

%typemap(in, numinputs=0) (int** matrixOut, int* matrixOutRowCount, int* matrixOutColCount)
{
}

%typemap(arginit) (int** matrixOut, int* matrixOutRowCount, int* matrixOutColCount)
{
  $1 = (int**) malloc(sizeof(int*));
  $2 = (int*) malloc(sizeof(int));
  $3 = (int*) malloc(sizeof(int));
}

%typemap(argout, fragment="SWIG_SciInt32_FromIntArrayAndSize") (int** matrixOut, int* matrixOutRowCount, int* matrixOutColCount)
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

%typemap(freearg) (int** matrixOut, int* matrixOutRowCount, int* matrixOutColCount)
{
  free(*$1);
  free($1);
  free($2);
  free($3);
}


// out (int* matrixOutRowCount, int* matrixOutColCount, int** matrixOut)

%typemap(in, numinputs=0) (int* matrixOutRowCount, int* matrixOutColCount, int** matrixOut)
{
}

%typemap(arginit) (int* matrixOutRowCount, int* matrixOutColCount, int** matrixOut)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (int*) malloc(sizeof(int));
  $3 = (int**) malloc(sizeof(int*));
}

%typemap(argout, fragment="SWIG_SciInt32_FromIntArrayAndSize") (int* matrixOutRowCount, int* matrixOutColCount, int** matrixOut)
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

%typemap(freearg) (int* matrixOutRowCount, int* matrixOutColCount, int** matrixOut)
{
  free($1);
  free($2);
  free(*$3);
  free($3);
}


// out (int** vectorOut, int* vectorOutSize)

%typemap(in, numinputs=0) (int** vectorOut, int* vectorOutSize)
{
}

%typemap(arginit) (int** vectorOut, int* vectorOutSize)
{
  $1 = (int**) malloc(sizeof(int*));
  $2 = (int*) malloc(sizeof(int));
}

%typemap(argout, fragment="SWIG_SciInt32_FromIntArrayAndSize") (int** vectorOut, int* vectorOutSize)
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

%typemap(freearg) (int** vectorOut, int* vectorOutSize)
{
  free(*$1);
  free($1);
  free($2);
}


// out (int* vectorOutSize, int** vectorOut)

%typemap(in, numinputs=0) (int* vectorOutSize, int** vectorOut)
{
}

%typemap(arginit) (int* vectorOutSize, int** vectorOut)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (int**) malloc(sizeof(int*));
}

%typemap(argout, fragment="SWIG_SciInt32_FromIntArrayAndSize") (int* vectorOutSize, int** vectorOut)
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

%typemap(freearg) (int* vectorInSize, int** vectorOut)
{
  free($1);
  free(*$2);
  free($2);
}

