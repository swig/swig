/*
 * C++ type: std::set<int>
 * Scilab 5 type: integer matrix
 */

%include <sciint.swg>

%typemap(in, fragment="SWIG_SciInt32_AsIntArrayAndSize") std::set<int>(std::set<int> temp)
{
  int* imatrix;
  int nbRows;
  int nbCols;
  if (SWIG_SciInt32_AsIntArrayAndSize(pvApiCtx, $input, &nbRows, &nbCols, &imatrix, fname) != SWIG_ERROR)
  {
    if ((nbRows > 1) && (nbCols > 1))
    {
      Scierror(999, _("%s: Wrong size for input argument #%d: An integer vector expected.\n"), fname, $input);
      return SWIG_ERROR;
    }

    $1 = temp;
    std::set<int>& tmpset = (std::set<int>&)$1;
    std::copy(imatrix, imatrix + nbRows * nbCols, std::inserter(tmpset, tmpset.begin()));
  }
}

%typemap(in, fragment="SWIG_SciInt32_AsIntArrayAndSize") std::set<int>& (std::set<int> temp)
{
  int* imatrix;
  int nbRows;
  int nbCols;
  if (SWIG_SciInt32_AsIntArrayAndSize(pvApiCtx, $input, &nbRows, &nbCols, &imatrix, fname) != SWIG_ERROR)
  {
    if ((nbRows > 1) && (nbCols > 1))
    {
      Scierror(999, _("%s: Wrong size for input argument #%d: An integer vector expected.\n"), fname, $input);
      return SWIG_ERROR;
    }

    $1 = &temp;
    std::set<int>& tmpset = *$1;
    std::copy(imatrix, imatrix + nbRows * nbCols, std::inserter(tmpset, tmpset.begin()));
  }
}


%typemap(out, fragment="SWIG_SciInt32_FromIntArrayAndSize") std::set<int>
{
  int nbCols = $1.size();
  int* imatrix = new int[nbCols];
  std::copy($1.begin(), $1.end(), imatrix);

  int ret = SWIG_SciInt32_FromIntArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, nbCols, imatrix);
  delete[] imatrix;

  if (ret != SWIG_ERROR)
  {
    AssignOutputVariable(pvApiCtx, outputPosition) = nbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition();
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(argout) std::set<int>&
{
  int nbCols = $1->size();
  int* imatrix = new int[nbCols];
  std::copy($1->begin(), $1->end(), imatrix);

  int ret = SWIG_SciInt32_FromIntArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, nbCols, imatrix);
  delete[] imatrix;

  if (ret != SWIG_ERROR)
  {
    AssignOutputVariable(pvApiCtx, outputPosition) = nbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition();
  }
  else
  {
    return SWIG_ERROR;
  }
}

