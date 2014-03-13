/*
 * C-type: bool array
 * Scilab type: bool matrix
 */

%include <scibool.swg>

// in (bool *matrixIn, int matrixInRowCount, int matrixInColCount)

%typemap(in, fragment="SWIG_SciBoolean_AsBoolArrayAndSize") (bool *matrixIn, int matrixInRowCount, int matrixInColCount)
{
  if (SWIG_SciBoolean_AsBoolArrayAndSize(pvApiCtx, $input, &$2, &$3, &$1, fname) != SWIG_OK)
  {
    return SWIG_ERROR;
  }
}

// in (int matrixInRowCount, int matrixInColCount, bool *matrixIn)

%typemap(in, fragment="SWIG_SciBoolean_AsBoolArrayAndSize") (int matrixInRowCount, int matrixInColCount, bool *matrixIn)
{
  if (SWIG_SciBoolean_AsBoolArrayAndSize(pvApiCtx, $input, &$1, &$2, &$3, fname) != SWIG_OK)
  {
    return SWIG_ERROR;
  }
}

// in (bool *vectorIn, int vectorInSize)

%typemap(in, fragment="SWIG_SciBoolean_AsBoolArrayAndSize") (bool *vectorIn, int vectorInSize)
{
    int rowCount;
    int colCount;
    if (SWIG_SciBoolean_AsBoolArrayAndSize(pvApiCtx, $input, &rowCount, &colCount, &$1, fname) == SWIG_OK)
    {
        $2 = rowCount * colCount;
    }
    else
    {
        return SWIG_ERROR;
    }
}

// in (int vectorInSize, bool *vectorIn)

%typemap(in) (int vectorInSize, bool *vectorIn)
{
    int rowCount;
    int colCount;
    if (SWIG_SciBoolean_AsBoolArrayAndSize(pvApiCtx, $input, &rowCount, &colCount, &$2, fname) == SWIG_OK)
    {
        $1 = rowCount * colCount;
    }
    else
    {
        return SWIG_ERROR;
    }
}

// out (bool **matrixOut, int *matrixOutRowCount, int *matrixOutColCount)

%typemap(in, numinputs=0) (bool **matrixOut, int *matrixOutRowCount, int *matrixOutColCount)
{
}

%typemap(arginit) (bool **matrixOut, int *matrixOutRowCount, int *matrixOutColCount)
{
  $1 = (bool**) malloc(sizeof(bool*));
  $2 = (int*) malloc(sizeof(int));
  $3 = (int*) malloc(sizeof(int));
}

%typemap(freearg) (bool **matrixOut, int *matrixOutRowCount, int *matrixOutColCount)
{
  free(*$1);
  free($1);
  free($2);
  free($3);
}

%typemap(argout, fragment="SWIG_SciBoolean_FromBoolArrayAndSize") (bool **matrixOut, int *matrixOutRowCount, int *matrixOutColCount)
{
  if (SWIG_SciBoolean_FromBoolArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), *$2, *$3, *$1) == SWIG_OK)
  {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else
  {
    return SWIG_ERROR;
  }
}

// out (int *matrixOutRowCount, int *matrixOutColCount, bool **matrixOut)

%typemap(in, numinputs=0) (int *matrixOutRowCount, int *matrixOutColCount, bool **matrixOut)
{
}

%typemap(arginit) (int *matrixOutRowCount, int *matrixOutColCount, bool **matrixOut)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (int*) malloc(sizeof(int));
  $3 = (bool**) malloc(sizeof(bool*));
}

%typemap(argout, fragment="SWIG_SciBoolean_FromBoolArrayAndSize") (int *matrixInRowCount, int *matrixInColCount, bool **matrixOut)
{
  if (SWIG_SciBoolean_FromBoolArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), *$1, *$2, *$3) == SWIG_OK)
  {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(freearg) (int *matrixOutRowCount, int *matrixOutColCount, bool **matrixOut)
{
  free($1);
  free($2);
  free(*$3);
  free($3);
}


// out (bool **vectorOut, int *vectorOutSize)

%typemap(in, numinputs=0) (bool **vectorOut, int *vectorOutSize)
{
}

%typemap(arginit) (bool **vectorOut, int *vectorOutSize)
{
  $1 = (bool**) malloc(sizeof(bool*));
  $2 = (int*) malloc(sizeof(int));
}

%typemap(argout, fragment="SWIG_SciBoolean_FromBoolArrayAndSize") (bool **vectorOut, int *vectorOutSize)
{
  if (SWIG_SciBoolean_FromBoolArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, *$2, *$1) == SWIG_OK)
  {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(freearg) (bool **vectorOut, int *vectorOutSize)
{
  free(*$1);
  free($1);
  free($2);
}


// out (int *vectorOutSize, bool **vectorOut)

%typemap(in, numinputs=0) (int *vectorOutSize, bool **vectorOut)
{
}

%typemap(arginit) (int *vectorOutSize, bool **vectorOut)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (bool**) malloc(sizeof(bool*));
}

%typemap(argout, fragment="SWIG_SciBoolean_FromBoolArrayAndSize") (int *vectorOutSize, bool **vectorOut)
{
  if (SWIG_SciBoolean_FromBoolArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, *$1, *$2) == SWIG_OK)
  {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(freearg) (int *vectorOutSize, bool **vectorOut)
{
  free($1);
  free(*$2);
  free($2);
}
