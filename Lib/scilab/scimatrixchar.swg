/*
 * C-type: char*
 * Scilab type: string matrix
 */

%include <scichar.swg>

// in (char** vectorIn, int vectorInSize)

%typemap(in, fragment="SwigScilabStringToCharPtrArrayAndSize") (char** vectorIn, int vectorInSize)
{
  if (SwigScilabStringToCharPtrArrayAndSize(pvApiCtx, $input, &$1, &$2, fname) == SWIG_ERROR)
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

%typemap(argout, fragment="SwigScilabStringFromCharPtrArray") (char*** vectorOut, int* vectorOutSize)
{
  if (SwigScilabStringFromCharPtrArray(pvApiCtx, SWIG_Scilab_GetOutputPosition(), *$1, *$2) != SWIG_ERROR)
  {
    AssignOutputVariable(pvApiCtx, outputPosition) = nbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition();
  }
  else
  {
    return SWIG_ERROR;
  }
}

// in (int vectorInSize, char** vectorIn)

%typemap(in, fragment="SwigScilabStringToCharPtrArrayAndSize") (int vectorInSize, char** vectorIn)
{
  if (SwigScilabStringToCharPtrArrayAndSize(pvApiCtx, $input, &$2, &$1, fname) == SWIG_ERROR)
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

%typemap(argout, fragment="SwigScilabStringFromCharPtrArray") (int* vectorOutSize, char*** vectorOut)
{
  if (SwigScilabStringFromCharPtrArray(pvApiCtx, SWIG_Scilab_GetOutputPosition(), *$2, *$1) != SWIG_ERROR)
  {
    AssignOutputVariable(pvApiCtx, outputPosition) = nbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition();
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

