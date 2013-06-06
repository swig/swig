/*
 * C++ type: std::vector<string>
 * Scilab 5 type: double matrix
 */

%include <scidouble.swg>

%typemap(in, fragment="SWIG_SciDouble_AsDoubleArrayAndSize") std::vector<string>(std::vector<string> temp)
{
  double* dmatrix;
  int nbRows;
  int nbCols;
  if (SWIG_SciDouble_AsDoubleArrayAndSize(pvApiCtx, $input, &nbRows, &nbCols, &dmatrix, fname) != SWIG_ERROR)
  {
    if ((nbRows > 1) && (nbCols > 1))
    {
      Scierror(999, _("%s: Wrong size for input argument #%d: A real vector expected.\n"), fname, $input);
      return SWIG_ERROR;
    }

    $1 = temp;
    $1.reserve(nbRows * nbCols);
    std::copy(dmatrix, dmatrix + nbRows * nbCols, std::back_inserter((std::vector<string>&)$1));
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(in, fragment="SWIG_SciDouble_AsDoubleArrayAndSize") std::vector<string>&(std::vector<string> temp)
{
  double* dmatrix;
  int nbRows;
  int nbCols;
  if (SWIG_SciDouble_AsDoubleArrayAndSize(pvApiCtx, $input, &nbRows, &nbCols, &dmatrix, fname) != SWIG_ERROR)
  {
    if ((nbRows > 1) && (nbCols > 1))
    {
      Scierror(999, _("%s: Wrong size for input argument #%d: A real vector expected.\n"), fname, $input);
      return SWIG_ERROR;
    }

    $1 = &temp;
    $1->reserve(nbRows * nbCols);
    std::copy(dmatrix, dmatrix + nbRows * nbCols, std::back_inserter(*$1));
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(out, fragment="SWIG_SciDouble_FromDoubleArrayAndSize") std::vector<string>
{
  int nbCols = $1.size();
  double* dmatrix = new double[nbCols];
  std::copy($1.begin(), $1.end(), dmatrix);

  int ret = SWIG_SciDouble_FromDoubleArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, nbCols, dmatrix);
  delete[] dmatrix;

  if (ret != SWIG_ERROR)
  {
    AssignOutputVariable(pvApiCtx, outputPosition) = nbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition();
  }
  else
  {
    return SWIG_ERROR;
  }
}

%typemap(argout, fragment="SWIG_SciDouble_FromDoubleArrayAndSize") std::vector<string>&
{
  int nbCols = $1->size();
  double* dmatrix = new double[nbCols];
  std::copy($1->begin(), $1->end(), dmatrix);

  int ret = SWIG_SciDouble_FromDoubleArrayAndSize(pvApiCtx, SWIG_Scilab_GetOutputPosition(), 1, nbCols, dmatrix);
  delete[] dmatrix;

  if (ret != SWIG_ERROR)
  {
    AssignOutputVariable(pvApiCtx, outputPosition) = nbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition();
  }
  else
  {
    return SWIG_ERROR;
  }
}




