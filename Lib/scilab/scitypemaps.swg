/* -----------------------------------------------------------------------------
 * --- Input arguments --- 
 * ----------------------------------------------------------------------------- */

/* Basic C types */
%typemap(in) signed char (int iRows, int iCols),
	     unsigned char (int iRows, int iCols),
	     short (int iRows, int iCols),
	     unsigned short (int iRows, int iCols),
	     int (int iRows, int iCols),
	     unsigned int (int iRows, int iCols),
	     long (int iRows, int iCols),
	     unsigned long (int iRows, int iCols),
	     float (int iRows, int iCols),
	     double (int iRows, int iCols),
         long long (int iRows, int iCols),
         unsigned long long (int iRows, int iCols) {
    int iType = 0;
    int *piAddrVar = NULL;
    double *_piData = NULL;
    
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_matrix)
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: A real expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }

    sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
    if (sciErr.iErr || iRows * iCols != 1)
    {
        Scierror(999, _("%s: Wrong size for input argument #%d: A real expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }
    $1 = ($1_ltype)*_piData;
}

%typemap(in) char (int iRows, int iCols) {   
    int iType = 0;
    int *piAddrVar = NULL;
    int typearg = 0;
    char *_pstStrings = NULL;
    int _piLength = 0;
    
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_strings)
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: A char string expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }
  
    _pstStrings = (char *)malloc(sizeof(char));
    sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, (char **)&_pstStrings);
    if (sciErr.iErr || iRows * iCols != 1)
    {
        Scierror(999, _("%s: Wrong size for input argument #%d: A char string expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }
    $1 = ($1_ltype)*_pstStrings;
  
    free(_pstStrings);
}

/* Pointers */
%typemap(in) signed char * (int iRows, int iCols),
             short * (int iRows, int iCols),
             unsigned char * (int iRows, int iCols),
             unsigned short * (int iRows, int iCols),
	         int * (int iRows, int iCols),
	         unsigned int * (int iRows, int iCols),
	         long * (int iRows, int iCols),
             unsigned long * (int iRows, int iCols),
             double * (int iRows, int iCols),
             float * (int iRows, int iCols),
             long long * (int iRows, int iCols),
             unsigned long long * (int iRows, int iCols) {
    int iType = 0;
    int *piAddrVar = NULL;
    void *_piData = NULL;
  
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr) 
    {
        printError(&sciErr, 0);
        return 0;
    }

    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_matrix)
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: A real expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }
  
    sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
    if (sciErr.iErr || iRows * iCols != 1)
    {
        Scierror(999, _("%s: Wrong size for input argument #%d: A real expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }
    $1 = ($1_ltype)_piData;
}

%typemap(in) char * (int iRows, int iCols) {
    int iType = 0;
    int *piAddrVar = NULL;
    char *_pstStrings = NULL;
    int _piLength = 0;
    
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_strings)
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: A string expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }  
    
    sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, NULL);
    if (sciErr.iErr || iRows * iCols != 1) 
    {
        Scierror(999, _("%s: Wrong size for input argument #%d: A string expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }
    
    _pstStrings = (char *)malloc(sizeof(char) * _piLength + 1);  
    sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, (char **)&_pstStrings);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    $1 = ($1_ltype)strdup(_pstStrings);
    
    free(_pstStrings);
}

%define SCILAB_IN_INTEGERVECTOR(CTYPE, INTTYPE, SCIAPIFUNCTION)
    int iPrec = 0;
    int *piAddrVar = NULL;
    CTYPE *_piData = NULL;
    size_t ii = 0;
    
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }  
  
    sciErr = getMatrixOfIntegerPrecision(pvApiCtx, piAddrVar, &iPrec);
    if (sciErr.iErr || iPrec != INTTYPE)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    sciErr = SCIAPIFUNCTION(pvApiCtx, piAddrVar, &iRows, &iCols, (CTYPE **)&_piData);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    for (ii = 0; ii < (size_t)iCols; ii++)
    {
        $1[ii] = ($*1_ltype)_piData[ii];
    }
%enddef

%typemap(in) signed char [ANY] (int iRows, int iCols)        { SCILAB_IN_INTEGERVECTOR(char, SCI_INT8, getMatrixOfInteger8) }
%typemap(in) unsigned char [ANY] (int iRows, int iCols)      { SCILAB_IN_INTEGERVECTOR(unsigned char, SCI_UINT8, getMatrixOfUnsignedInteger8) }
%typemap(in) short [ANY] (int iRows, int iCols)              { SCILAB_IN_INTEGERVECTOR(short, SCI_INT16, getMatrixOfInteger16) }
%typemap(in) unsigned short [ANY] (int iRows, int iCols)     { SCILAB_IN_INTEGERVECTOR(unsigned short, SCI_UINT16, getMatrixOfUnsignedInteger16) }
%typemap(in) int [ANY] (int iRows, int iCols)                { SCILAB_IN_INTEGERVECTOR(int, SCI_INT32, getMatrixOfInteger32) }
%typemap(in) long [ANY] (int iRows, int iCols)               { SCILAB_IN_INTEGERVECTOR(long, SCI_INT32, getMatrixOfInteger32) }
%typemap(in) unsigned int [ANY] (int iRows, int iCols)       { SCILAB_IN_INTEGERVECTOR(unsigned int, SCI_UINT32, getMatrixOfUnsignedInteger32) }
%typemap(in) unsigned long [ANY] (int iRows, int iCols)      { SCILAB_IN_INTEGERVECTOR(unsigned long, SCI_UINT32, getMatrixOfUnsignedInteger32) }
%typemap(in) long long [ANY] (int iRows, int iCols)          { SCILAB_IN_INTEGERVECTOR(long long, SCI_INT64, getMatrixOfInteger64) }
%typemap(in) unsigned long long [ANY] (int iRows, int iCols) { SCILAB_IN_INTEGERVECTOR(unsigned long long, SCI_UINT64, getMatrixOfUnsignedInteger64) }

%typemap(in) double [ANY] (int iRows, int iCols),
             float [ANY] (int iRows, int iCols) {
    int iType = 0;
    int *piAddrVar = NULL;
    double *_piData = NULL;
    size_t ii = 0;
    
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }

    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_matrix)
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }
 
    sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    for (ii = 0; ii < (size_t)iCols; ii++)
    {
        $1[ii] = ($*1_ltype)_piData[ii];
    }
}

%typemap(in) char [ANY] (int iRows, int iCols) {
    int iType = 0;
    int *piAddrVar = NULL;
    char *_pstStrings = NULL;
    int _piLength = 0;
    
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr) 
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_strings) 
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: A string expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }  
    
    sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, NULL);
    if (sciErr.iErr || iRows * iCols != 1) 
    {
        Scierror(999, _("%s: Wrong size for input argument #%d: A string expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }
    
    _pstStrings = (char *)malloc(sizeof(char) * _piLength + 1);
    sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, (char **)&_pstStrings);
    if (sciErr.iErr) 
    {
        printError(&sciErr, 0);
        return 0;
    }
    $1 = ($1_ltype)strdup(_pstStrings);
    
    free(_pstStrings);
}

%define SCILAB_IN_INTEGERVECTOR_WITHALLOC(CTYPE, INTTYPE, SCIAPIFUNCTION)
    int iPrec = 0;
    int *piAddrVar = NULL;
    CTYPE *_piData = NULL;
    size_t ii = 0;
    
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }  
  
    sciErr = getMatrixOfIntegerPrecision(pvApiCtx, piAddrVar, &iPrec);
    if (sciErr.iErr || iPrec != INTTYPE)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    sciErr = SCIAPIFUNCTION(pvApiCtx, piAddrVar, &iRows, &iCols, (CTYPE **)&_piData);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    $1 = ($1_ltype)malloc(sizeof($*1_ltype) * iCols);
    for (ii = 0; ii < (size_t)iCols; ii++)
    {
        $1[ii] = ($*1_ltype)_piData[ii];
    }
%enddef

%typemap(in) signed char [] (int iRows, int iCols)        { SCILAB_IN_INTEGERVECTOR_WITHALLOC(char, SCI_INT8, getMatrixOfInteger8) }
%typemap(in) unsigned char [] (int iRows, int iCols)      { SCILAB_IN_INTEGERVECTOR_WITHALLOC(unsigned char, SCI_UINT8, getMatrixOfUnsignedInteger8) }
%typemap(in) short [] (int iRows, int iCols)              { SCILAB_IN_INTEGERVECTOR_WITHALLOC(short, SCI_INT16, getMatrixOfInteger16) }
%typemap(in) unsigned short [] (int iRows, int iCols)     { SCILAB_IN_INTEGERVECTOR_WITHALLOC(unsigned short, SCI_UINT16, getMatrixOfUnsignedInteger16) }
%typemap(in) int [] (int iRows, int iCols)                { SCILAB_IN_INTEGERVECTOR_WITHALLOC(int, SCI_INT32, getMatrixOfInteger32) }
%typemap(in) long [] (int iRows, int iCols)               { SCILAB_IN_INTEGERVECTOR_WITHALLOC(long, SCI_INT32, getMatrixOfInteger32) }
%typemap(in) unsigned int [] (int iRows, int iCols)       { SCILAB_IN_INTEGERVECTOR_WITHALLOC(unsigned int, SCI_UINT32, getMatrixOfUnsignedInteger32) }
%typemap(in) unsigned long [] (int iRows, int iCols)      { SCILAB_IN_INTEGERVECTOR_WITHALLOC(unsigned long, SCI_UINT32, getMatrixOfUnsignedInteger32) }
%typemap(in) long long [] (int iRows, int iCols)          { SCILAB_IN_INTEGERVECTOR_WITHALLOC(long long, SCI_INT64, getMatrixOfInteger64) }
%typemap(in) unsigned long long [] (int iRows, int iCols) { SCILAB_IN_INTEGERVECTOR_WITHALLOC(unsigned long long, SCI_UINT64, getMatrixOfUnsignedInteger64) }

%typemap(in) double [] (int iRows, int iCols),
             float [] (int iRows, int iCols) {
    int iType = 0;
    int *piAddrVar = NULL;
    double *_piData = NULL;
    size_t ii = 0;
  
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_matrix) 
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar  expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }

    sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
 
    $1 = ($1_ltype)malloc(sizeof($*1_ltype) * iCols);
    for (ii = 0; ii < (size_t)iCols; ii++)
    {
        $1[ii] = ($*1_ltype)_piData[ii];
    }
}

/* Arrays */
%define SCILAB_IN_INTEGERMATRIX(CTYPE, INTTYPE, SCIAPIFUNCTION)
    int iPrec = 0;
    int *piAddrVar = NULL;
    CTYPE *_piData = NULL;
    size_t ii = 0;
    size_t jj = 0;
  
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    sciErr = getMatrixOfIntegerPrecision(pvApiCtx, piAddrVar, &iPrec);
    if (sciErr.iErr || iPrec != INTTYPE)
    {
        printError(&sciErr, 0);
        return 0;
    }

    sciErr = SCIAPIFUNCTION(pvApiCtx, piAddrVar, &iRows, &iCols, (CTYPE **)&_piData);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    for (ii = 0; ii < (size_t)iRows; ii++)
    {
        for (jj = 0; jj < (size_t)iCols; jj++)
        {
            $1[ii][jj] = ($1_basetype)_piData[jj * iRows + ii];
        }
    }
}
%typemap(in) signed char [ANY][ANY] (int iRows, int iCols)        { SCILAB_IN_INTEGERMATRIX(char, SCI_INT8, getMatrixOfInteger8) }
%typemap(in) unsigned char [ANY][ANY] (int iRows, int iCols)      { SCILAB_IN_INTEGERMATRIX(unsigned char, SCI_UINT8, getMatrixOfUnsignedInteger8) }
%typemap(in) short [ANY][ANY] (int iRows, int iCols)              { SCILAB_IN_INTEGERMATRIX(short, SCI_INT16, getMatrixOfInteger16) }
%typemap(in) unsigned short [ANY][ANY] (int iRows, int iCols)     { SCILAB_IN_INTEGERMATRIX(unsigned short, SCI_UINT16, getMatrixOfUnsignedInteger16) }
%typemap(in) int [ANY][ANY] (int iRows, int iCols)                { SCILAB_IN_INTEGERMATRIX(int, SCI_INT32, getMatrixOfInteger32) }
%typemap(in) long [ANY][ANY] (int iRows, int iCols)               { SCILAB_IN_INTEGERMATRIX(long, SCI_INT32, getMatrixOfInteger32) }
%typemap(in) unsigned int [ANY][ANY] (int iRows, int iCols)       { SCILAB_IN_INTEGERMATRIX(unsigned int, SCI_UINT32, getMatrixOfUnsignedInteger32) }
%typemap(in) unsigned long [ANY][ANY] (int iRows, int iCols)      { SCILAB_IN_INTEGERMATRIX(unsigned long, SCI_UINT32, getMatrixOfUnsignedInteger32) }
%typemap(in) long long [ANY][ANY] (int iRows, int iCols)          { SCILAB_IN_INTEGERMATRIX(long long, SCI_INT64, getMatrixOfInteger64) }
%typemap(in) unsigned long long [ANY][ANY] (int iRows, int iCols) { SCILAB_IN_INTEGERMATRIX(unsigned long long, SCI_UINT64, getMatrixOfUnsignedInteger64) }

%typemap(in) double [ANY][ANY] (int iRows, int iCols),
             float [ANY][ANY] (int iRows, int iCols) {
    int iType = 0;
    int *piAddrVar = NULL;
    double *_piData = NULL;
    size_t ii = 0;
    size_t jj = 0;
  
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_matrix) 
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar  expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }

    sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    for (ii = 0; ii < (size_t)iRows; ii++)
    {
        for (jj = 0; jj < (size_t)iCols; jj++)
        {
            $1[ii][jj] = ($1_basetype)_piData[jj * iRows + ii];
        }
    }
}

%typemap(in) enum SWIGTYPE (int iRows, int iCols) {
    int iPrec = 0;
    int *piAddrVar = NULL;
    int *_piData = NULL;
    
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr) 
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    sciErr = getMatrixOfIntegerPrecision(pvApiCtx, piAddrVar, &iPrec);
    if (sciErr.iErr || iPrec != SCI_INT32) 
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    sciErr = getMatrixOfInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (int **)&_piData);
    if (sciErr.iErr) 
    {
        printError(&sciErr, 0);
        return 0;
    }
    $1 = ($1_ltype)*_piData;
}

%typemap(in) SWIGTYPE *,
             SWIGTYPE [] {
    int iType = 0;
    int *piAddrVar = NULL;
    void *_piData = NULL;
  
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr) 
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_pointer) 
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: Pointer  expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }

    sciErr = getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
    if (sciErr.iErr) 
    {
        printError(&sciErr, 0);
        return 0;
    }
    $1 = ($1_ltype)_piData;
}

%typemap(in) SWIGTYPE {
    int iType = 0;
    int *piAddrVar = NULL;
    void *_piData = NULL;
  
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_pointer)
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }

    sciErr = getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    $1 = *(($&1_ltype)_piData);
}

/* -----------------------------------------------------------------------------
 * --- Output arguments --- 
 * ----------------------------------------------------------------------------- */

%define SCILAB_OUT_SCALAR(CTYPE, SCIAPIFUNCTION)
    iRowsOut = 1;
    iColsOut = 1;
    
    sciErr = SCIAPIFUNCTION(pvApiCtx, iVarOut, iRowsOut, iColsOut, (CTYPE *)&$result);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    LhsVar(iOutNum) = iVarOut;
    iOutNum++;
    iVarOut++;
%enddef
%define SCILAB_OUT_SCALAR_WITHCAST(CASTTYPE, SCIAPIFUNCTION)
    CASTTYPE temp = (CASTTYPE) $result;
    iRowsOut = 1;
    iColsOut = 1;
    
    sciErr = SCIAPIFUNCTION(pvApiCtx, iVarOut, iRowsOut, iColsOut, &temp);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    LhsVar(iOutNum) = iVarOut;
    iOutNum++;
    iVarOut++;
%enddef

/* Basic C types */
/* 'signed char' casted to 'char' because C++ refuses to call createMatrixOfInteger8 with a 'signed char' 5th input */
%typemap(out) signed char (int iRowsOut, int iColsOut)                 { SCILAB_OUT_SCALAR_WITHCAST(char, createMatrixOfInteger8) }
%typemap(out) unsigned char (int iRowsOut, int iColsOut)               { SCILAB_OUT_SCALAR(unsigned char, createMatrixOfUnsignedInteger8) }
%typemap(out) short (int iRowsOut, int iColsOut)                       { SCILAB_OUT_SCALAR_WITHCAST(double, createMatrixOfDouble) }
%typemap(out) unsigned short (int iRowsOut, int iColsOut)              { SCILAB_OUT_SCALAR(unsigned short, createMatrixOfUnsignedInteger16) }
%typemap(out) int (int iRowsOut, int iColsOut)                         { SCILAB_OUT_SCALAR_WITHCAST(double, createMatrixOfDouble) }
%typemap(out) long (int iRowsOut, int iColsOut)                        { SCILAB_OUT_SCALAR_WITHCAST(double, createMatrixOfDouble) }
%typemap(out) unsigned int (int iRowsOut, int iColsOut)                { SCILAB_OUT_SCALAR(unsigned int, createMatrixOfUnsignedInteger32) }
%typemap(out) unsigned long (int iRowsOut, int iColsOut)               { SCILAB_OUT_SCALAR_WITHCAST(unsigned int, createMatrixOfUnsignedInteger32) }
%typemap(out) double (int iRowsOut, int iColsOut)                      { SCILAB_OUT_SCALAR(double, createMatrixOfDouble) }
%typemap(out) float (int iRowsOut, int iColsOut)                       { SCILAB_OUT_SCALAR_WITHCAST(double, createMatrixOfDouble) }
%typemap(out) long long (int iRowsOut, int iColsOut)                   { SCILAB_OUT_SCALAR(long long, createMatrixOfInteger64) }
%typemap(out) unsigned long long (int iRowsOut, int iColsOut)          { SCILAB_OUT_SCALAR(unsigned long long, createMatrixOfUnsignedInteger64) }
%typemap(out) SCI_INT16_FROM_SHORT (int iRowsOut, int iColsOut)        { SCILAB_OUT_SCALAR(short, createMatrixOfInteger16) }
%typemap(out) SCI_INT16_FROM_SIGNED_SHORT (int iRowsOut, int iColsOut) { SCILAB_OUT_SCALAR_WITHCAST(short, createMatrixOfInteger16) }
%typemap(out) SCI_INT32_FROM_INT (int iRowsOut, int iColsOut)          { SCILAB_OUT_SCALAR(int, createMatrixOfInteger32) }
%typemap(out) SCI_INT32_FROM_SIGNED_INT (int iRowsOut, int iColsOut)   { SCILAB_OUT_SCALAR_WITHCAST(int, createMatrixOfInteger32) }
%typemap(out) SCI_INT32_FROM_LONG (int iRowsOut, int iColsOut)         { SCILAB_OUT_SCALAR_WITHCAST(int, createMatrixOfInteger32) }
%typemap(out) SCI_INT32_FROM_SIGNED_LONG (int iRowsOut, int iColsOut)  { SCILAB_OUT_SCALAR_WITHCAST(int, createMatrixOfInteger32) }

%typemap(out) char (int iRowsOut, int iColsOut) {
    iRowsOut = 1;
    iColsOut = 1;
    
    char *temp = (char*)MALLOC(sizeof(char) * (iRowsOut * iColsOut + 1));
    temp[0] = $result;
    temp[1] = '\0';
    
    sciErr = createMatrixOfString(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char **)&temp);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    FREE(temp);
    
    LhsVar(iOutNum) = iVarOut;
    iOutNum++;
    iVarOut++;
}

%typemap(out,noblock=1) void {
}


/* Pointers */
%typemap(out, warning="Pointers") signed char * (int iRowsOut, int iColsOut),
              short * (int iRowsOut, int iColsOut),
              unsigned char * (int iRowsOut, int iColsOut),
              unsigned short * (int iRowsOut, int iColsOut),
	      int * (int iRowsOut, int iColsOut),
	      unsigned int * (int iRowsOut, int iColsOut),
	      long * (int iRowsOut, int iColsOut),
	      unsigned long * (int iRowsOut, int iColsOut),
              double * (int iRowsOut, int iColsOut),
              float * (int iRowsOut, int iColsOut),
              long long * (int iRowsOut, int iColsOut),
              unsigned long long * (int iRowsOut, int iColsOut) {
    sciErr = createMatrixOfDouble(pvApiCtx, iVarOut, iRowsOut, iColsOut, (double *)$result);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    LhsVar(iOutNum) = iVarOut;
    iOutNum++;
    iVarOut++;  
}

%typemap(out) double * (int iRowsOut, int iColsOut) {
    sciErr = createMatrixOfDouble(pvApiCtx, iVarOut, *$2, *$3, (double *)*$1);
    if (sciErr.iErr) {
        printError(&sciErr, 0);
        return 0;
    }
    
    LhsVar(iOutNum) = iVarOut;
    iOutNum++;
    iVarOut++;
}

%typemap(out) char * (int iRowsOut, int iColsOut) {
    iRowsOut = 1; 
    iColsOut = 1;
  
    sciErr = createMatrixOfString(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char **)&($result));
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    LhsVar(iOutNum) = iVarOut;
    iOutNum++;
    iVarOut++;
}

%typemap(out) enum SWIGTYPE (int iRowsOut, int iColsOut) {
    iRowsOut = 1; 
    iColsOut = 1;
  
    sciErr = createMatrixOfInteger32(pvApiCtx, iVarOut, iRowsOut, iColsOut, (int *)&$result);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    LhsVar(iOutNum) = iVarOut;
    iOutNum++;
    iVarOut++;
}

%typemap(out) SWIGTYPE * {
    sciErr = createPointer(pvApiCtx, iVarOut, (void *)$result);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    LhsVar(iOutNum) = iVarOut;
    iOutNum++;
    iVarOut++;  
}

%typemap(out) SWIGTYPE {
    sciErr = createPointer(pvApiCtx, iVarOut, %new_copy($result, $1_ltype));
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    LhsVar(iOutNum) = iVarOut;
    iOutNum++;
    iVarOut++;  
}

/* -----------------------------------------------------------------------------
 * --- Variable input --- 
 * ----------------------------------------------------------------------------- */

%typemap(varin,noblock=1) signed char,
	                  unsigned char,
	                  short,
	                  unsigned short,
	                  int,
	                  unsigned int,
	                  long,
	                  unsigned long,
	                  float,
	                  double,
                          long long,
                          unsigned long long {
    int iType = 0;
    double *_piData = NULL;
  
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr) 
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_matrix)
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: A Real expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }

    sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
    if (sciErr.iErr || iRows * iCols != 1)
    {
        Scierror(999, _("%s: Wrong size for input argument #%d: A real expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }
    $1 = ($1_ltype)*_piData;
}

%typemap(varin,noblock=1) char {   
    int iType = 0;
    char *_pstStrings = NULL;
    int _piLength = 0;
    
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_strings) 
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: A char string expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }
    
    _pstStrings = (char *) malloc(sizeof(char));
    sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, (char **)&_pstStrings);
    if (sciErr.iErr || iRows * iCols != 1) 
    {
        Scierror(999, _("%s: Wrong size for input argument #%d: A char string expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }
    $1 = ($1_ltype)*_pstStrings;
    
    free(_pstStrings);
}

%typemap(varin,noblock=1) char * {
    int iType = 0;
    char *_pstStrings = NULL;
    int _piLength = 0;
    
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr) 
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_strings) 
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: A string expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }
    
    sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, NULL);
    if (sciErr.iErr || iRows * iCols != 1) 
    {
        Scierror(999, _("%s: Wrong size for input argument #%d: A string expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }
    
    _pstStrings = (char *)malloc(sizeof(char) * _piLength + 1);
    sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, (char **)&_pstStrings);
    if (sciErr.iErr) 
    {
        printError(&sciErr, 0);
        return 0;
    }
    $1 = ($1_ltype)strdup(_pstStrings);
    
    free(_pstStrings);
}

%typemap(varin,noblock=1) char [ANY] {
    int iType = 0;
    char *_pstStrings = NULL;
    int _piLength = 0;
  
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_strings)
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: A string expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }

    sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, NULL);
    if (sciErr.iErr || iRows * iCols != 1)
    {
        Scierror(999, _("%s: Wrong size for input argument #%d: A string expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }
  
    _pstStrings = (char *)malloc(sizeof(char) * _piLength);
    sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, (char **)&_pstStrings);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    strcpy($1, _pstStrings);
  
    free(_pstStrings);
}

%define SCILAB_VARIN_INTEGERVECTOR(CTYPE, INTTYPE, SCIAPIFUNCTION) 
    int iPrec = 0;
    CTYPE *_piData = NULL;
    size_t ii = 0;
  
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
 
    sciErr = getMatrixOfIntegerPrecision(pvApiCtx, piAddrVar, &iPrec);
    if (sciErr.iErr || iPrec != INTTYPE)
    {
        printError(&sciErr, 0);
        return 0;
    }

    sciErr = SCIAPIFUNCTION(pvApiCtx, piAddrVar, &iRows, &iCols, (CTYPE **)&_piData);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    for (ii = 0; ii < (size_t)$1_dim0; ii++)
    {
        $1[ii] = ($*1_ltype)_piData[ii];
    }
%enddef

%typemap(varin,noblock=1) signed char [ANY]        { SCILAB_VARIN_INTEGERVECTOR(signed char, SCI_INT8, getMatrixOfInteger8) }
%typemap(varin,noblock=1) unsigned char [ANY]      { SCILAB_VARIN_INTEGERVECTOR(unsigned char, SCI_UINT8, getMatrixOfUnsignedInteger8) }
%typemap(varin,noblock=1) short [ANY]              { SCILAB_VARIN_INTEGERVECTOR(short, SCI_INT16, getMatrixOfInteger16) }
%typemap(varin,noblock=1) unsigned short [ANY]     { SCILAB_VARIN_INTEGERVECTOR(unsigned short, SCI_UINT16, getMatrixOfUnsignedInteger16) }
%typemap(varin,noblock=1) int [ANY]                { SCILAB_VARIN_INTEGERVECTOR(int, SCI_INT32, getMatrixOfInteger32) }
%typemap(varin,noblock=1) long [ANY]               { SCILAB_VARIN_INTEGERVECTOR(long, SCI_INT32, getMatrixOfInteger32) }
%typemap(varin,noblock=1) unsigned int [ANY]       { SCILAB_VARIN_INTEGERVECTOR(unsigned int, SCI_UINT32, getMatrixOfUnsignedInteger32) }
%typemap(varin,noblock=1) unsigned long [ANY]      { SCILAB_VARIN_INTEGERVECTOR(unsigned long, SCI_UINT32, getMatrixOfUnsignedInteger32) }
%typemap(varin,noblock=1) long long [ANY]          { SCILAB_VARIN_INTEGERVECTOR(long long, SCI_INT64, getMatrixOfInteger64) }
%typemap(varin,noblock=1) unsigned long long [ANY] { SCILAB_VARIN_INTEGERVECTOR(unsigned long long, SCI_UINT64, getMatrixOfUnsignedInteger64) }

%typemap(varin,noblock=1) double [ANY],
                          float [ANY] {
    int iType = 0;
    double *_piData = NULL;
    size_t ii = 0;
  
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_matrix)
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar  expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }

    sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    for (ii = 0; ii < (size_t)$1_dim0; ii++)
    {
        $1[ii] = ($*1_ltype)_piData[ii];
    }
}

%typemap(varin,noblock=1) signed char *,
                          short *,
                          unsigned char *,
                          unsigned short *,
                          int *,
	                      unsigned int *,
	                      long *,
	                      unsigned long *,
                          double *,
                          float *, 
                          long long *,
                          unsigned long long * {
    int iType = 0;
    void *_piData = NULL;
    
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }

    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_pointer)
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: Pointer  expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }

    sciErr = getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    $1 = ($1_ltype)_piData;
}

%typemap(varin,noblock=1) char ** {
    int iType = 0;
    char **_pstStrings = NULL;
    int *_piLength = NULL;
    int i = 0;
    
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_strings)
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: string matrix expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }
    
    _piLength = (int*)malloc(sizeof(int) * iRows * iCols);
    sciErr = getMatrixOfString(pvApiCtxpiAddrVar, &iRows, &iCols, _piLength, NULL);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    _pstStrings = (char**)malloc(iRows * iCols * sizeof(char*));
    for(i = 0; i < iRows * iCols; i++)
    {
        _pstStrings[i] = (char*)malloc((_piLength[i] + 1) * sizeof(char));
    }
    
    sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, _piLength, (char **)_pstStrings);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    $1 = _pstStrings;
    free(_piLength);
    free(_pstStrings);
}

/* Arrays */
%define SCILAB_VARIN_INTEGERMATRIX(CTYPE, INTTYPE, SCIAPIFUNCTION)
    int iPrec = 0;
    CTYPE *_piData = NULL;
    size_t ii = 0;
    size_t jj = 0;
    
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    sciErr = getMatrixOfIntegerPrecision(pvApiCtx, piAddrVar, &iPrec);
    if (sciErr.iErr || iPrec != INTTYPE)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    sciErr = SCIAPIFUNCTION(pvApiCtx, piAddrVar, &iRows, &iCols, (CTYPE **)&_piData);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
   
    for (ii = 0; ii < (size_t)$1_dim0; ii++)
    {
        for (jj = 0; jj < (size_t)$1_dim1; jj++)
        {
            $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
        }
    }
%enddef

%typemap(varin,noblock=1) signed char [ANY][ANY]                            { SCILAB_VARIN_INTEGERMATRIX(signed char, SCI_INT8, getMatrixOfInteger8) }
%typemap(varin,noblock=1) unsigned char [ANY][ANY]                          { SCILAB_VARIN_INTEGERMATRIX(unsigned char, SCI_UINT8, getMatrixOfUnsignedInteger8) }
%typemap(varin,noblock=1) short [ANY][ANY]                                  { SCILAB_VARIN_INTEGERMATRIX(short, SCI_INT16, getMatrixOfInteger16) }
%typemap(varin,noblock=1) unsigned short [ANY][ANY]                         { SCILAB_VARIN_INTEGERMATRIX(unsigned short, SCI_UINT16, getMatrixOfUnsignedInteger16) }
%typemap(varin,noblock=1) int [ANY][ANY], long [ANY][ANY]                   { SCILAB_VARIN_INTEGERMATRIX(int, SCI_INT32, getMatrixOfInteger32) }
%typemap(varin,noblock=1) unsigned int [ANY][ANY], unsigned long [ANY][ANY] { SCILAB_VARIN_INTEGERMATRIX(unsigned int, SCI_UINT32, getMatrixOfUnsignedInteger32) }
%typemap(varin,noblock=1) unsigned long [ANY][ANY]                          { SCILAB_VARIN_INTEGERMATRIX(unsigned long, SCI_UINT32, getMatrixOfUnsignedInteger32) }
%typemap(varin,noblock=1) long long [ANY][ANY]                              { SCILAB_VARIN_INTEGERMATRIX(long long, SCI_INT64, getMatrixOfInteger64) }
%typemap(varin,noblock=1) unsigned long long [ANY][ANY]                     { SCILAB_VARIN_INTEGERMATRIX(unsigned long long, SCI_UINT64, getMatrixOfUnsignedInteger64) }

%typemap(varin,noblock=1) double [ANY][ANY],
                          float [ANY][ANY] {
    int iType = 0;
    double *_piData = NULL;
    size_t ii = 0;
    size_t jj = 0;
    
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr) 
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_matrix) 
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar  expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }
    
    sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
    if (sciErr.iErr) 
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    for (ii = 0; ii < (size_t)$1_dim0; ii++)
    {
        for (jj = 0; jj < (size_t)$1_dim1; jj++)
        {
            $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
        }
    }
}

%typemap(varin,noblock=1) enum SWIGTYPE {
    int iPrec = 0;
    int *_piData = NULL;
    
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr) 
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    sciErr = getMatrixOfIntegerPrecision(pvApiCtx, piAddrVar, &iPrec);
    if (sciErr.iErr || iPrec != SCI_INT32) 
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    sciErr = getMatrixOfInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (int **)&_piData);
    if (sciErr.iErr) 
    {
        printError(&sciErr, 0);
        return 0;
    }
    $1 = ($1_ltype)*_piData;
}
%typemap(varin,noblock=1) SWIGTYPE * {
    int iType = 0;
    void *_piData = NULL;
    
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_pointer) 
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: Pointer  expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }
    
    sciErr = getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
    if (sciErr.iErr) 
    {
        printError(&sciErr, 0);
        return 0;
    }
    $1 = ($1_ltype)_piData;
}

%typemap(varin,noblock=1) SWIGTYPE [ANY] {
    int iType = 0;
    void *_piData = NULL;
    size_t ii = 0;
    
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr) 
    {
        printError(&sciErr, 0);
        return 0;
    }  
    
    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_pointer) 
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: Pointer  expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }
    
    sciErr = getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
    if (sciErr.iErr) 
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    for (ii = 0; ii < $1_dim0; ii++)
    {
        $1[ii] = (($1_ltype)_piData)[ii];
    }
}

%typemap(varin,noblock=1) SWIGTYPE [ANY][ANY] {
    int iType = 0;
    void *_piData = NULL;
    size_t ii = 0;
    size_t jj = 0;
    
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr) 
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_pointer)
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: Pointer  expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }
    
    sciErr = getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
    if (sciErr.iErr) 
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    for (ii = 0; ii < (size_t)$1_dim0; ii++)
    {
        for (jj = 0; jj < (size_t)$1_dim1; jj++)
        { /* Fill the two dim array. Note that a Scilab matrix is stored as a flat matrix by columns */
            $1[ii][jj] = (($1_basetype *)_piData)[jj * $1_dim0+ii];
        }
    }
}

%typemap(varin,nobloack=1) SWIGTYPE {
    int iType = 0;
    void *_piData = NULL;
    
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    sciErr = getVarType(pvApiCtx, piAddrVar, &iType);
    if (sciErr.iErr || iType != sci_pointer)
    {
        Scierror(999, _("%s: Wrong type for input argument #%d: Pointer  expected.\n"), fname, $argnum);
        printError(&sciErr, 0);
        return 0;
    }
    
    sciErr = getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    $1 = *(($&1_ltype)_piData);
}

/* -----------------------------------------------------------------------------
 * --- Variable output --- 
 * ----------------------------------------------------------------------------- */

%define SCILAB_SCALAR_VAROUT(CTYPE, SCIAPIFUNCTION)
    CTYPE temp = $result;
    
    sciErr = SCIAPIFUNCTION(pvApiCtx, iVarOut, iRowsOut, iColsOut, (CTYPE *)&temp);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    LhsVar(iOutNum) = iVarOut;
    iOutNum++;
    iVarOut++;
%enddef

/* Basic C types */
%typemap(varout,noblock=1) signed char                 { SCILAB_SCALAR_VAROUT(signed char, createMatrixOfInteger8)                 }
%typemap(varout,noblock=1) unsigned char               { SCILAB_SCALAR_VAROUT(unsigned char, createMatrixOfUnsignedInteger8)       }
%typemap(varout,noblock=1) signed short                { SCILAB_SCALAR_VAROUT(signed short, createMatrixOfInteger16)               }
%typemap(varout,noblock=1) unsigned short              { SCILAB_SCALAR_VAROUT(unsigned short, createMatrixOfUnsignedInteger16)     }
%typemap(varout,noblock=1) signed int, signed long     { SCILAB_SCALAR_VAROUT(signed int, createMatrixOfInteger32)                 }
%typemap(varout,noblock=1) unsigned int, unsigned long { SCILAB_SCALAR_VAROUT(unsigned int, createMatrixOfUnsignedInteger32)       }
%typemap(varout,noblock=1) signed long long            { SCILAB_SCALAR_VAROUT(signed long long, createMatrixOfInteger64)           }
%typemap(varout,noblock=1) unsigned long long          { SCILAB_SCALAR_VAROUT(unsigned long long, createMatrixOfUnsignedInteger64) }
%typemap(varout,noblock=1) double, float               { SCILAB_SCALAR_VAROUT(double, createMatrixOfDouble)                        }

%typemap(varout,noblock=1) char {
    char *temp = (char *)malloc(sizeof($result) + 1);
    *temp = $result;
    *(temp+1) = '\0';
    
    sciErr = createMatrixOfString(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char **)&temp);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    LhsVar(iOutNum) = iVarOut;
    iOutNum++;
    iVarOut++;
    free(temp);
}

%typemap(varout,noblock=1) char * {
    char *temp = $result;
    
    sciErr = createMatrixOfString(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char **)&temp);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    LhsVar(iOutNum) = iVarOut;
    iOutNum++;
    iVarOut++;
}

/* pointer to basic C types */
%typemap(varout,noblock=1) signed char *,
                           short *,
                           unsigned char *,
                           unsigned short *,
                           int *,
                           unsigned int *,
                           long *,
                           unsigned long *,
                           double *,
                           float *,
                           long long *,
                           unsigned long long * {
    sciErr = createPointer(pvApiCtx, iVarOut, (void *)$result);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    LhsVar(iOutNum) = iVarOut;
    iOutNum++;
    iVarOut++;
}

/* Arrays */
%define SCILAB_VAROUT(CTYPE, SCIAPIFUNCTION, IROWSOUT, ICOLSOUT)
    sciErr = SCIAPIFUNCTION(pvApiCtx, iVarOut, IROWSOUT, ICOLSOUT, (CTYPE *)$result);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    LhsVar(iOutNum) = iVarOut;
    iOutNum++;
    iVarOut++;
%enddef

%typemap(varout,noblock=1) char [ANY] {
    char **pstData = NULL;
    pstData = (char **)malloc(sizeof(char *));
    pstData[0] = $result;
    
    sciErr = createMatrixOfString(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char **)pstData);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    LhsVar(iOutNum) = iVarOut;
    iOutNum++;
    iVarOut++;
}

%typemap(varout,noblock=1) signed char [ANY]                       { SCILAB_VAROUT(char, createMatrixOfInteger8, 1, $1_dim0) }
%typemap(varout,noblock=1) unsigned char [ANY]                     { SCILAB_VAROUT(unsigned char, createMatrixOfUnsignedInteger8, 1, $1_dim0) }
%typemap(varout,noblock=1) short [ANY]                             { SCILAB_VAROUT(short, createMatrixOfInteger16, 1, $1_dim0) }
%typemap(varout,noblock=1) unsigned short [ANY]                    { SCILAB_VAROUT(unsigned short, createMatrixOfUnsignedInteger16, 1, $1_dim0) }
%typemap(varout,noblock=1) int [ANY], long [ANY]                   { SCILAB_VAROUT(int, createMatrixOfInteger32, 1, $1_dim0) }
%typemap(varout,noblock=1) unsigned int [ANY], unsigned long [ANY] { SCILAB_VAROUT(int, createMatrixOfUnsignedInteger32, 1, $1_dim0) }
%typemap(varout,noblock=1) long long [ANY]                         { SCILAB_VAROUT(long long, createMatrixOfInteger64, 1, $1_dim0) }
%typemap(varout,noblock=1) unsigned long long [ANY]                { SCILAB_VAROUT(unsigned long long, createMatrixOfUnsignedInteger64, 1, $1_dim0) }
%typemap(varout,noblock=1) double [ANY], float [ANY]               { SCILAB_VAROUT(double, createMatrixOfDouble, 1, $1_dim0) }

%typemap(varout,noblock=1) char ** {
    char **pstData = NULL;
    pstData = (char **)malloc(iRowsOut * iColsOut * sizeof(char*));
    pstData = $result;
  
    sciErr = createMatrixOfString(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char **)pstData);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    LhsVar(iOutNum) = iVarOut;
    iOutNum++;
    iVarOut++;
}

%typemap(varout,noblock=1) signed char [ANY][ANY], char [ANY][ANY]           { SCILAB_VAROUT(char, createMatrixOfInteger8, $1_dim0, $1_dim0) }
%typemap(varout,noblock=1) unsigned char [ANY][ANY]                          { SCILAB_VAROUT(unsigned char, createMatrixOfUnsignedInteger8, $1_dim0, $1_dim0) }
%typemap(varout,noblock=1) short [ANY][ANY]                                  { SCILAB_VAROUT(short, createMatrixOfInteger16, $1_dim0, $1_dim0) }
%typemap(varout,noblock=1) unsigned short [ANY][ANY]                         { SCILAB_VAROUT(unsigned short, createMatrixOfUnsignedInteger16, $1_dim0, $1_dim0) }
%typemap(varout,noblock=1) int [ANY][ANY], long [ANY][ANY]                   { SCILAB_VAROUT(int, createMatrixOfInteger32, $1_dim0, $1_dim0) }
%typemap(varout,noblock=1) unsigned int [ANY][ANY], unsigned long [ANY][ANY] { SCILAB_VAROUT(int, createMatrixOfUnsignedInteger32, $1_dim0, $1_dim0) }
%typemap(varout,noblock=1) long long [ANY][ANY]                              { SCILAB_VAROUT(long long, createMatrixOfInteger64, $1_dim0, $1_dim0) }
%typemap(varout,noblock=1) unsigned long long [ANY][ANY]                     { SCILAB_VAROUT(unsigned long long, createMatrixOfUnsignedInteger64, $1_dim0, $1_dim0) }
%typemap(varout,noblock=1) double [ANY][ANY], float [ANY][ANY]               { SCILAB_VAROUT(double, createMatrixOfDouble, $1_dim0, $1_dim0) }

/* Enums */
%typemap(varout,noblock=1) enum SWIGTYPE {
    sciErr = createMatrixOfInteger32(pvApiCtx, iVarOut, iRowsOut, iColsOut, (int *)&$result);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
  
    LhsVar(iOutNum) = iVarOut;
    iOutNum++;
    iVarOut++;
}

/* Other types */
%typemap(varout,noblock=1) SWIGTYPE * {
    sciErr = createPointer(pvApiCtx, iVarOut, (void *)$result);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    LhsVar(iOutNum) = iVarOut;
    iOutNum++;
    iVarOut++;
}

%typemap(varout,noblock=1) SWIGTYPE {
    sciErr = createPointer(pvApiCtx, iVarOut, (void *)&$result);
    if (sciErr.iErr) 
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    LhsVar(iOutNum) = iVarOut;
    iOutNum++;
    iVarOut++;
}

/* -----------------------------------------------------------------------------*/
/* Typecheck typemaps */
/* -----------------------------------------------------------------------------*/

%define SCILAB_TYPECHECK(SCITYPE)
    int *piAddrVar = NULL;
    int iType      = 0;
    
    sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
    if (sciErr.iErr)
    {
        printError(&sciErr, 0);
        return 0;
    }
    
    getVarType(pvApiCtx, piAddrVar, &iType);
    
    $1 = (iType == SCITYPE) ? 1 : 0;
%enddef

/* Scilab equivalent for C integers can be sci_ints or sci_matrix */
%define SCILAB_INTEGERTYPECHECK(INTTYPE)
    SCILAB_TYPECHECK(sci_ints)
    if ($1 == 1) /* sci_ints type */
    {
        int iPrec = 0;
        
        sciErr = getMatrixOfIntegerPrecision(pvApiCtx, piAddrVar, &iPrec);
        if (sciErr.iErr)
        {
            printError(&sciErr, 0);
            return 0;
        }
        
        $1 = (iPrec == INTTYPE) ? 1 : 0;
    }
    else /* sci_matrix type */
    {
        SCILAB_TYPECHECK(sci_matrix)
    }
%enddef

/* -----------------------------------------------------------------------------*/
/* Basic C types */
/* -----------------------------------------------------------------------------*/
%typecheck(SWIG_TYPECHECK_CHAR)         char                                    { SCILAB_TYPECHECK(sci_strings)       }

/* * TODO: add an option to select default integers mapping? */
/* C-integers mapped to Scilab sci_matrix (TODO: add int64 & uint64 for Scilab 6) */
%typecheck(SWIG_TYPECHECK_INT8)         signed char                             { SCILAB_TYPECHECK(sci_matrix)        }
%typecheck(SWIG_TYPECHECK_UINT8)        unsigned char                           { SCILAB_TYPECHECK(sci_matrix)        }
%typecheck(SWIG_TYPECHECK_INT16)        short                                   { SCILAB_TYPECHECK(sci_matrix)        }
%typecheck(SWIG_TYPECHECK_UINT16)       unsigned short                          { SCILAB_TYPECHECK(sci_matrix)        }
%typecheck(SWIG_TYPECHECK_INT32)        int, long                               { SCILAB_TYPECHECK(sci_matrix)        }
%typecheck(SWIG_TYPECHECK_UINT32)       unsigned int, unsigned long             { SCILAB_TYPECHECK(sci_matrix)        }
/* C-integers mapped to Scilab integers (TODO: add int64 & uint64 for Scilab 6) */
/*
%typecheck(SWIG_TYPECHECK_INT8)         signed char                             { SCILAB_INTEGERTYPECHECK(SCI_INT8)   }
%typecheck(SWIG_TYPECHECK_UINT8)        unsigned char                           { SCILAB_INTEGERTYPECHECK(SCI_UINT8)  }
%typecheck(SWIG_TYPECHECK_INT16)        short                                   { SCILAB_INTEGERTYPECHECK(SCI_INT16)  }
%typecheck(SWIG_TYPECHECK_UINT16)       unsigned short                          { SCILAB_INTEGERTYPECHECK(SCI_UINT16) }
%typecheck(SWIG_TYPECHECK_INT32)        int, long                               { SCILAB_INTEGERTYPECHECK(SCI_INT32)  }
%typecheck(SWIG_TYPECHECK_UINT32)       unsigned int, unsigned long             { SCILAB_INTEGERTYPECHECK(SCI_UINT32) }
*/

%typecheck(SWIG_TYPECHECK_DOUBLE)       double                                  { SCILAB_TYPECHECK(sci_matrix)        }
%typecheck(SWIG_TYPECHECK_FLOAT)        float                                   { SCILAB_TYPECHECK(sci_matrix)        }
%typecheck(SWIG_TYPECHECK_STRING)       char *                                  { SCILAB_TYPECHECK(sci_strings)       }

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE * { SCILAB_TYPECHECK(sci_pointer) }

/* -----------------------------------------------------------------------------*/
/* Arrays */
/* -----------------------------------------------------------------------------*/
%typecheck(SWIG_TYPECHECK_CHAR_ARRAY)   char [ANY]                              { SCILAB_TYPECHECK(sci_strings)       }

/* * TODO: add an option to select default integers mapping? */
/* C-integers mapped to Scilab sci_matrix (TODO: add int64 & uint64 for Scilab 6) */
%typecheck(SWIG_TYPECHECK_INT8_ARRAY)   signed char [ANY]                       { SCILAB_TYPECHECK(sci_matrix)        }
//%typecheck(SWIG_TYPECHECK_UINT8_ARRAY)  unsigned char [ANY]                     { SCILAB_TYPECHECK(sci_matrix)        }
%typecheck(SWIG_TYPECHECK_INT16_ARRAY)  short [ANY]                             { SCILAB_TYPECHECK(sci_matrix)        }
//%typecheck(SWIG_TYPECHECK_UINT16_ARRAY) unsigned short [ANY]                    { SCILAB_TYPECHECK(sci_matrix)        }
%typecheck(SWIG_TYPECHECK_INT32_ARRAY)  int [ANY], long [ANY]                   { SCILAB_TYPECHECK(sci_matrix)        }
//%typecheck(SWIG_TYPECHECK_UINT32_ARRAY) unsigned int [ANY], unsigned long [ANY] { SCILAB_TYPECHECK(sci_matrix)        }
/* C-integers mapped to Scilab integers (TODO: add int64 & uint64 for Scilab 6) */
/*
%typecheck(SWIG_TYPECHECK_INT8_ARRAY)   signed char [ANY]                       { SCILAB_INTEGERTYPECHECK(SCI_INT8)   }
%typecheck(SWIG_TYPECHECK_UINT8_ARRAY)  unsigned char [ANY]                     { SCILAB_INTEGERTYPECHECK(SCI_UINT8)  }
%typecheck(SWIG_TYPECHECK_INT16_ARRAY)  short [ANY]                             { SCILAB_INTEGERTYPECHECK(SCI_INT16)  }
%typecheck(SWIG_TYPECHECK_UINT16_ARRAY) unsigned short [ANY]                    { SCILAB_INTEGERTYPECHECK(SCI_UINT16) }
%typecheck(SWIG_TYPECHECK_INT32_ARRAY)  int [ANY], long [ANY]                   { SCILAB_INTEGERTYPECHECK(SCI_INT32)  }
%typecheck(SWIG_TYPECHECK_UINT32_ARRAY) unsigned int [ANY], unsigned long [ANY] { SCILAB_INTEGERTYPECHECK(SCI_INT32)  }
*/

%typecheck(SWIG_TYPECHECK_DOUBLE_ARRAY) double [ANY]                            { SCILAB_TYPECHECK(sci_matrix)        }
%typecheck(SWIG_TYPECHECK_FLOAT_ARRAY)  float [ANY]                             { SCILAB_TYPECHECK(sci_matrix)        }
%typecheck(SWIG_TYPECHECK_STRING_ARRAY) char **                                 { SCILAB_TYPECHECK(sci_strings)       }

/* -----------------------------------------------------------------------------*/
/* size_t mapped as int */
/* -----------------------------------------------------------------------------*/
%apply int { size_t };


