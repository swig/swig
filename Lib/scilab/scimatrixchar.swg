/*
 * C-type: char*
 * Scilab type: string matrix
 */

%include <scichar.swg>

// in (char **matrixIn, int matrixInRowCount, int matrixInColCount)

%typemap(in, noblock=1, fragment="SWIG_SciString_AsCharPtrArrayAndSize") (char **matrixIn, int matrixInRowCount, int matrixInColCount)
{
  if (SWIG_SciString_AsCharPtrArrayAndSize(pvApiCtx, $input, &$2, &$3, &$1, fname) != SWIG_OK)
  {
    return SWIG_ERROR;
  }
}

// in (int matrixInRowCount, int matrixInColCount, char **matrixIn)

%typemap(in, noblock=1, fragment="SWIG_SciString_AsCharPtrArrayAndSize") (int matrixInRowCount, int matrixInColCount, char **matrixIn)
{
  if (SWIG_SciString_AsCharPtrArrayAndSize(pvApiCtx, $input, &$1, &$2, &$3, fname) != SWIG_OK)
  {
    return SWIG_ERROR;
  }
}

// in (char **matrixIn, int matrixInSize)

%typemap(in, noblock=1, fragment="SWIG_SciString_AsCharPtrArrayAndSize") (char **matrixIn, int matrixInSize)
{
  int rowCount;
  int colCount;
  if (SWIG_SciString_AsCharPtrArrayAndSize(pvApiCtx, $input, &rowCount, &colCount, &$1, fname) == SWIG_OK)
  {
    $2 = rowCount * colCount;
  }
  else
  {
    return SWIG_ERROR;
  }
}

// in (int matrixInSize, char **matrixIn)

%typemap(in, noblock=1, fragment="SWIG_SciString_AsCharPtrArrayAndSize") (int matrixInSize, char **matrixIn)
{
  int rowCount;
  int colCount;
  if (SWIG_SciString_AsCharPtrArrayAndSize(pvApiCtx, $input, &rowCount, &colCount, &$2, fname) == SWIG_OK)
  {
    $1 = rowCount * colCount;
  }
  else
  {
    return SWIG_ERROR;
  }
}

// out (char ***matrixOut, int *matrixOutRowCount, int *matrixOutColCount)

%typemap(in, noblock=1, numinputs=0) (char ***matrixOut, int *matrixOutRowCount, int *matrixOutColCount)
{
}

%typemap(arginit, noblock=1) (char ***matrixOut, int *matrixOutRowCount, int *matrixOutColCount)
{
  $1 = (char***) malloc(sizeof(char**));
  $2 = (int*) malloc(sizeof(int));
  $3 = (int*) malloc(sizeof(int));
}

%typemap(argout, noblock=1, fragment="SWIG_SciString_FromCharPtrArrayAndSize") (char ***matrixOut, int *matrixOutRowCount, int *matrixOutColCount)
{
  if (SWIG_SciString_FromCharPtrArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), *$2, *$3, *$1) == SWIG_OK)
  {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(freearg, noblock=1) (char ***matrixOut, int *matrixOutRowCount, int *matrixOutColCount)
{
  {
    int i;
    for (i = 0; i < (*$2) * (*$3); i++)
      free((*$1)[i]);
  }
  free(*$1);
  free($1);
  free($2);
  free($3);
}

// out (int *matrixOutRowCount, int *matrixOutColCount, char ***matrixOut)

%typemap(in, noblock=1, numinputs=0) (int *matrixOutRowCount, int *matrixOutColCount, char ***matrixOut)
{
}

%typemap(arginit, noblock=1) (int *matrixOutRowCount, int *matrixOutColCount, char ***matrixOut)
{
  $1 = (char***) malloc(sizeof(char**));
  $2 = (int*) malloc(sizeof(int));
  $3 = (int**) malloc(sizeof(int*));
}

%typemap(argout, noblock=1, fragment="SWIG_SciString_FromCharPtrArrayAndSize") (int *matrixOutRowCount, int *matrixOutColCount, char ***matrixOut)
{
  if (SWIG_SciString_FromCharPtrArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), *$1, *$2, *$3) == SWIG_OK)
  {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(freearg, noblock=1) (int *matrixOutRowCount, int *matrixOutColCount, char ***matrixOut)
{
  free($1);
  free($2);
  {
    int i;
    for (i = 0; i < (*$1) * (*$2); i++)
      free((*$3)[i]);
  }
  free(*$3);
  free($3);
}


// out (char ***matrixOut, int *matrixOutSize)

%typemap(in, noblock=1, numinputs=0) (char ***matrixOut, int *matrixOutSize)
{
}

%typemap(arginit, noblock=1) (char ***matrixOut, int *matrixOutSize)
{
  $1 = (char***) malloc(sizeof(char**));
  $2 = (int*) malloc(sizeof(int));
}

%typemap(freearg, noblock=1) (char ***matrixOut, int *matrixOutSize)
{
  {
    int i;
    for (i = 0; i < *$2; i++)
      free((*$1)[i]);
  }
  free(*$1);
  free($1);
  free($2);
}

%typemap(argout, noblock=1, fragment="SWIG_SciString_FromCharPtrArrayAndSize") (char ***matrixOut, int *matrixOutSize)
{
  if (SWIG_SciString_FromCharPtrArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, *$2, *$1) == SWIG_OK)
  {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else
  {
    return SWIG_ERROR;
  }
}

// in (int matrixInSize, char **matrixIn)

%typemap(in, noblock=1, fragment="SWIG_SciString_AsCharPtrArrayAndSize") (int matrixInSize, char **matrixIn)
{
  if (SWIG_SciString_AsCharPtrArrayAndSize(pvApiCtx, $input, 1, &$1, &$2, fname) != SWIG_OK)
  {
    return SWIG_ERROR;
  }
}

// out (int *matrixOutSize, char ***matrixOut)

%typemap(in, noblock=1, numinputs=0) (int *matrixOutSize, char ***matrixOut)
{
}

%typemap(arginit, noblock=1) (int *matrixOutSize, char ***matrixOut)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (char***) malloc(sizeof(char**));
}

%typemap(argout, noblock=1, fragment="SWIG_SciString_FromCharPtrArrayAndSize") (int *matrixOutSize, char ***matrixOut)
{
  if (SWIG_SciString_FromCharPtrArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, *$1, *$2) == SWIG_OK)
  {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(freearg, noblock=1) (int *matrixOutSize, char ***matrixOut)
{
  free($1);
  {
    int i;
    for (i = 0; i < *$1; i++)
      free((*$2)[i]);
  }
  free(*$2);
  free($2);
}

