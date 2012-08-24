/*
  Vectors typemaps
*/

// Typemap for input arguments of type const std::vector<double> &
%typecheck(SWIG_TYPECHECK_POINTER)
  const std::vector<double> &
{
    // TODO
}
%typemap(in)
  const std::vector<double> &
(int is_new_object=0, std::vector<double> arrayv)
{
    {
        SciErr sciErr;
        int iRows = 0;
        int iCols = 0;
        int *piAddrVar = NULL;
        double *pdblTmp = NULL;

        /* Scilab value must be a double vector */
        sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
        if (sciErr.iErr) {
            printError(&sciErr, 0);
            return SWIG_ERROR;
        }

        if (isDoubleType(pvApiCtx, piAddrVar) && !isVarComplex(pvApiCtx, piAddrVar)) {
            sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, &pdblTmp);
            if (sciErr.iErr) {
                printError(&sciErr, 0);
                return SWIG_ERROR;
            }
        } else {
            Scierror(999, _("%s: Wrong type for input argument #%d: A real vector expected.\n"), fname, $input);
            return SWIG_ERROR;
        }

        if ((iRows!=1) && (iCols!=1)) {
            Scierror(999, _("%s: Wrong size for input argument #%d: A real vector expected.\n"), fname, $input);
            return SWIG_ERROR;
        }
        /* Copy vector contents into new allocated std::vector<double> */
        arrayv = std::vector<double>(iRows*iCols);
        $1 = &arrayv;
        {
            int arr_i = 0;
            for (arr_i = 0; arr_i < iRows*iCols; ++arr_i)
                arrayv[arr_i] = pdblTmp[arr_i];
        }
    }
}
%typemap(freearg)
  const std::vector<double> &
{
    // TODO
}

// Typemap for return values of type std::vector<double>
%typemap(out) std::vector<double>
{
    // TODO
}
