/*
 * C-type: char*
 * Scilab type: string matrix
 */

%include <scichar.swg>

// in (char** vectorIn, int vectorInSize)

%typemap(in, fragment="SWIG_SciString_AsCharPtrArrayAndSize") (char** vectorIn, int vectorInSize)
{
  if (SWIG_SciString_AsCharPtrArrayAndSize(pvApiCtx, $input, &$1, &$2, fname) != SWIG_OK)
  {
    return SWIG_ERROR;
  }
}

// out (char*** vectorOut, int* vectorOutSize)

%typemap(in, numinputs=0) (char*** vectorOut, int* vectorOutSize)
{
}

%typemap(arginit) (char*** vectorOut, int* vectorOutSize)
{
  $1 = (char***) malloc(sizeof(char**));
  $2 = (int*) malloc(sizeof(int));
}

%typemap(freearg) (char*** vectorOut, int* vectorOutSize)
{
  free(*(*$1));
  free(*$1);
  free($1);
  free($2);
}

%typemap(argout, fragment="SWIG_SciString_FromCharPtrArray") (char*** vectorOut, int* vectorOutSize)
{
  if (SWIG_SciString_FromCharPtrArray(pvApiCtx, SWIG_Scilab_GetOutputPosition(), *$1, *$2) == SWIG_OK)
  {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else
  {
    return SWIG_ERROR;
  }
}

// in (int vectorInSize, char** vectorIn)

%typemap(in, fragment="SWIG_SciString_AsCharPtrArrayAndSize") (int vectorInSize, char** vectorIn)
{
  if (SWIG_SciString_AsCharPtrArrayAndSize(pvApiCtx, $input, &$2, &$1, fname) != SWIG_OK)
  {
    return SWIG_ERROR;
  }
}

// out (int* vectorOutSize, char*** vectorOut)

%typemap(in, numinputs=0) (int* vectorOutSize, char*** vectorOut)
{
}

%typemap(arginit) (int* vectorOutSize, char*** vectorOut)
{
  $1 = (int*) malloc(sizeof(int));
  $2 = (char***) malloc(sizeof(char**));
}

%typemap(argout, fragment="SWIG_SciString_FromCharPtrArray") (int* vectorOutSize, char*** vectorOut)
{
  if (SWIG_SciString_FromCharPtrArray(pvApiCtx, SWIG_Scilab_GetOutputPosition(), *$2, *$1) == SWIG_OK)
  {
    SWIG_Scilab_SetOutput(pvApiCtx, SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition());
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(freearg) (int* vectorOutSize, char*** vectorOut)
{
  free($1);
  free(*(*$2));
  free(*$2);
  free($2);
}

