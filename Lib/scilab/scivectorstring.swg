/*
 * C++ type: std::vector<std::string>
 * Scilab 5 type: string matrix
 */

%include <scichar.swg>

%typemap(in, fragment="SwigScilabStringToCharPtrArrayAndSize") std::vector<std::string>(std::vector<std::string> temp)
{
  char** charArray;
  int charArraySize;

  int ret = SwigScilabStringToCharPtrArrayAndSize(pvApiCtx, $input, &charArray, &charArraySize, fname);
  if (ret == SWIG_OK)
  {
    $1 = temp;
    $1.reserve(charArraySize);
    std::copy(charArray, charArray + charArraySize, std::back_inserter((std::vector<std::string>&)$1));

    for (int i=0; i<charArraySize; i++)
      free(charArray[i]);
    free(charArray);
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(in, fragment="SwigScilabStringToCharPtrArrayAndSize") std::vector<std::string>&(std::vector<std::string> temp)
{
  char** charArray;
  int charArraySize;

  int ret = SwigScilabStringToCharPtrArrayAndSize(pvApiCtx, $input, &charArray, &charArraySize, fname);
  if (ret == SWIG_OK)
  {
    $1 = &temp;
    $1->reserve(charArraySize);
    std::copy(charArray, charArray + charArraySize, std::back_inserter(*$1));

    for (int i=0; i<charArraySize; i++)
      free(charArray[i]);
    free(charArray);
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(out, fragment="SwigScilabStringFromCharPtrArray") std::vector<std::string>
{
  int pCharArraySize = $1.size();
  char** pCharArray = new char*[pCharArraySize];
  char** p = pCharArray;
  for (std::vector<std::string>::iterator it = $1.begin(); it != $1.end(); it++)
  {
    char* pChar = new char(it->size()+1);
    strcpy(pChar, it->c_str());
    *p = pChar;
    p++;
  }

  int ret = SwigScilabStringFromCharPtrArray(pvApiCtx, SWIG_Scilab_GetOutputPosition(), pCharArray, pCharArraySize);
  delete[] pCharArray;

  if (ret != SWIG_ERROR)
  {
    AssignOutputVariable(pvApiCtx, outputPosition) = nbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition();
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(argout, fragment="SwigScilabStringFromCharPtrArray") std::vector<std::string>&
{
  int pCharArraySize = $1->size();
  char** pCharArray = new char*[pCharArraySize];
  char** p = pCharArray;
  for (std::vector<std::string>::iterator it = $1->begin(); it != $1->end(); it++)
  {
    char* pChar = new char(it->size()+1);
    strcpy(pChar, it->c_str());
    *p = pChar;
    p++;
  }

  int ret = SwigScilabStringFromCharPtrArray(pvApiCtx, SWIG_Scilab_GetOutputPosition(), pCharArray, pCharArraySize);
  delete[] pCharArray;

  if (ret != SWIG_ERROR)
  {
    AssignOutputVariable(pvApiCtx, outputPosition) = nbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition();
  }
  else
  {
    return SWIG_ERROR;
  }
}




