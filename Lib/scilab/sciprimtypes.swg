%fragment("SWIG_AsCharPtrAndSize","header") {
SWIGINTERN int
SWIG_AsCharPtrAndSize(int iPos, char** cptr, size_t* psize, int *alloc)
{
    SciErr sciErr;
    int iType = 0;
    int *piAddrVar = NULL;
    char *_pstStrings = NULL;
    int _piLength = 0;
    int iCols = 0;
    int iRows = 0;

    sciErr = getVarAddressFromPosition(pvApiCtx, iPos, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return SWIG_ERROR;
    }

    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_strings)
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: A string expected.\n"), "SWIG_AsCharPtrAndSize", iPos);
        printError(&sciErr, 0);
        return SWIG_TypeError;
    }

    sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, NULL);
    if (sciErr.iErr || iRows * iCols != 1)
    {
        Scierror(999, _("%s: Wrong size for input argument #%d: A string expected.\n"), "SWIG_AsCharPtrAndSize", iPos);
        printError(&sciErr, 0);
        return SWIG_TypeError;
    }

    _pstStrings = (char *)malloc(sizeof(char) * _piLength + 1);
    sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, (char**)&_pstStrings);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return SWIG_ERROR;
    }
    if (cptr) 
    {
       *cptr = _pstStrings;
    }
    if (psize)
    {
        *psize = _piLength + 1;
    }
    if (alloc) 
    {
        *alloc = SWIG_OLDOBJ;
    }
    return SWIG_OK;

}
}
%fragment("SWIG_FromCharPtrAndSize","header") {
SWIGINTERNINLINE int
SWIG_FromCharPtrAndSize(const char* carray, size_t size)
{
    SciErr sciErr;
    int iVarOut = Rhs + 1; // TODO is this always true?
    sciErr = createMatrixOfString(pvApiCtx, iVarOut, 1, 1, (char **)&carray);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return SWIG_ERROR;
    }
      return SWIG_OK;
}
}

%fragment(SWIG_AsVal_frag(long),"header") {
SWIGINTERN int SWIG_AsVal_dec(long)(int iPos, long* val)
{
    SciErr sciErr;
    int iRows = 1;
    int iCols = 1;
    int iType = 0;
    int* piAddrVar = NULL;
    double* piData = NULL;
    double v = 0.0;

    sciErr = getVarAddressFromPosition(pvApiCtx, iPos, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return SWIG_TypeError;
    }

    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return SWIG_TypeError;
    }
    if (iType != sci_matrix)
    {
        return SWIG_TypeError;
    }

    if (isVarComplex(pvApiCtx, piAddrVar))
    {
        return SWIG_TypeError;
    }

    sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&piData);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return SWIG_TypeError;
    }
    if (iRows * iCols != 1)
    {
        return SWIG_TypeError;
    }

    v = piData[0];
    if (v != floor(v))
    {
        return SWIG_TypeError;
    }

    if (val != NULL)
    {
        *val = (long) piData[0];
    }

    return SWIG_OK;
}
}

%fragment(SWIG_From_frag(long),"header") {
SWIGINTERNINLINE int SWIG_From_dec(long)  (long value)
{
    double dblValue = (double) value;
    if (createScalarDouble(pvApiCtx, Rhs + 1, dblValue) == 0)
    {
        return SWIG_OK;
    }
    return SWIG_ERROR;
}
}

/*%fragment(SWIG_AsPtr_frag(std::string),"header") {
SWIGINTERN int
SWIG_AsPtr_std_string(int iPos, std::string **val)
{
    char* buf = 0;
    size_t size = 0;
    int alloc = SWIG_OLDOBJ;

    if (SWIG_IsOK((SWIG_AsCharPtrAndSize(iPos, &buf, &size, &alloc))))
    {
        if (buf)
        {
                if (val)
                {
                    *val = new std::string(buf, size - 1);
                }
                if (alloc == SWIG_NEWOBJ)
                {
                    delete[] buf;
                }
                return SWIG_NEWOBJ;
        }
        else
        {
            if (val)
            {
                *val = 0;
            }
            return SWIG_OLDOBJ;
        }
    }
    else
    {
        return SWIG_ERROR;
    }
}
}*/
