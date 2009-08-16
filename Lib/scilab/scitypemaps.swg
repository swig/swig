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
  int *piAddrVar;
  double *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_matrix || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(piAddrVar, &iRows, &iCols, (double **)&_piData);
  $1 = ($1_ltype)*_piData;
}

%typemap(in) char (int iRows, int iCols) {   
  int *piAddrVar;
  char *_pstStrings;
  int _piLength;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
    
  if (getVarType(piAddrVar) != sci_strings || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfString(piAddrVar, &iRows, &iCols,&_piLength, (char **)&_pstStrings);
  $1 = ($1_ltype)*_pstStrings;
}

/* Pointers */
%typemap(in) signed char *,
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
  int *piAddrVar;
  void *_piData = NULL;
  getVarAddressFromPosition($argnum, &piAddrVar);
  
  if (getVarType(piAddrVar) != sci_lufact_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
  getPointer(piAddrVar, (void **)&_piData);
  $1 = ($1_ltype)_piData;
}

%typemap(in) char * (int iRows, int iCols){
  int *piAddrVar;
  char *_pstStrings;
  int _piLength;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_strings || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfString(piAddrVar, &iRows, &iCols, &_piLength, NULL);
  _pstStrings = (char *)malloc(sizeof(char) * _piLength + 1);
  getMatrixOfString(piAddrVar, &iRows, &iCols, &_piLength, (char **)&_pstStrings);
  $1 = ($1_ltype)strdup(_pstStrings);
  free(_pstStrings);
}

%typemap(in) signed char [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  char *_piData;
  size_t ii = 0;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger8(piAddrVar, &iRows, &iCols, (char **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) unsigned char [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  unsigned char *_piData;
  size_t ii = 0;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger8(piAddrVar, &iRows, &iCols, (unsigned char **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) short [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  short *_piData;
  size_t ii = 0;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger16(piAddrVar, &iRows, &iCols, (short **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) unsigned short [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  unsigned short *_piData;
  size_t ii = 0;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger16(piAddrVar, &iRows, &iCols, (unsigned short **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) int [ANY] (int iRows, int iCols),
	     long [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int *_piData;
  size_t ii = 0;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger32(piAddrVar, &iRows, &iCols, (int **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) unsigned int [ANY] (int iRows, int iCols),
	     unsigned long [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  unsigned int *_piData;
  size_t ii = 0;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger32(piAddrVar, &iRows, &iCols, (unsigned int **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) double [ANY] (int iRows, int iCols),
             float [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  double *_piData;
  size_t ii = 0;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_matrix || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(piAddrVar, &iRows, &iCols, (double **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++){
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) long long [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  long long *_piData;
  size_t ii = 0;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger64(piAddrVar, &iRows, &iCols, (long long **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++){
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) unsigned long long [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  unsigned long long *_piData;
  size_t ii = 0;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger64(piAddrVar, &iRows, &iCols, (unsigned long long **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++){
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) char [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  char *_pstStrings;
  int _piLength;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_strings || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfString(piAddrVar, &iRows, &iCols,&_piLength, (char **)&_pstStrings);
  $1 = ($1_ltype)strdup(_pstStrings);
}

/* Arrays */
%typemap(in) signed char [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  char *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger8(piAddrVar, &iRows, &iCols, (char **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(in) unsigned char [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  unsigned char *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger8(piAddrVar, &iRows, &iCols, (unsigned char **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(in) short [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  short *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger16(piAddrVar, &iRows, &iCols, (short **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(in) unsigned short [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  unsigned short *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger16(piAddrVar, &iRows, &iCols, (unsigned short **)&_piData);
 
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(in) int [ANY][ANY] (int iRows, int iCols), 
             long [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger32(piAddrVar, &iRows, &iCols, (int **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(in) unsigned int [ANY][ANY] (int iRows, int iCols), 
             unsigned long [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  unsigned int *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger32(piAddrVar, &iRows, &iCols, (unsigned int **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(in) double [ANY][ANY] (int iRows, int iCols),
             float [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  double *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_matrix || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(piAddrVar, &iRows, &iCols, (double **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(in) long long [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  long long *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger64(piAddrVar, &iRows, &iCols, (long long **)&_piData);

  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(in) unsigned long long [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  unsigned long long *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger64(piAddrVar, &iRows, &iCols, (unsigned long long **)&_piData);

  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(in) enum SWIGTYPE (int iRows, int iCols) {
  int *piAddrVar;
  int *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger32(piAddrVar, &iRows, &iCols, (int **)&_piData);
  $1 = ($1_ltype)*_piData;
}

%typemap(in) SWIGTYPE * {
  int *piAddrVar;
  void *_piData = NULL;
  getVarAddressFromPosition($argnum, &piAddrVar);
  
  if (getVarType(piAddrVar) != sci_lufact_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
  getPointer(piAddrVar, (void **)&_piData);
  $1 = ($1_ltype)_piData;
}

%typemap(in) SWIGTYPE {
  int *piAddrVar;
  void *_piData = NULL;
  getVarAddressFromPosition($argnum, &piAddrVar);
  
  if (getVarType(piAddrVar) != sci_lufact_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
  getPointer(piAddrVar, (void **)&_piData);
  $1 = *(($&1_ltype)_piData);
}

/* -----------------------------------------------------------------------------
 * --- Output arguments --- 
 * ----------------------------------------------------------------------------- */

/* Basic C types */
%typemap(out) signed char (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfInteger8(iVarOut, iRowsOut, iColsOut, (char *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) unsigned char (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfUnsignedInteger8(iVarOut, iRowsOut, iColsOut, (unsigned char *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) short (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfInteger16(iVarOut, iRowsOut, iColsOut, (short *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) unsigned short (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfUnsignedInteger16(iVarOut, iRowsOut, iColsOut, (unsigned short *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) int (int iRowsOut, int iColsOut),
              long (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfInteger32(iVarOut, iRowsOut, iColsOut, (int *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) unsigned int (int iRowsOut, int iColsOut),
              unsigned long (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfUnsignedInteger32(iVarOut, iRowsOut, iColsOut, (unsigned int *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) double (int iRowsOut, int iColsOut),
              float (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfDouble(iVarOut, iRowsOut, iColsOut, (double *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) long long (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfInteger64(iVarOut, iRowsOut, iColsOut, (long long *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) unsigned long long (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfUnsignedInteger64(iVarOut, iRowsOut, iColsOut, (unsigned long long *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) char (int iRowsOut, int iColsOut) {
  char *temp;
  temp = (char*)&($result);
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfString(iVarOut, iRowsOut, iColsOut, (char **)&temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out,noblock=1) void {
}


/* Pointers */
%typemap(out) signed char *,
              short *,
              unsigned char *,
              unsigned short *,
	      int *,
	      unsigned int *,
	      long *,
	      unsigned long *,
              double *,
              float *,
              long long,
              unsigned long long * {
  createPointer(iVarOut, (void *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) char * (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfString(iVarOut, iRowsOut, iColsOut, (char **)&($result));
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) enum SWIGTYPE (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfInteger32(iVarOut, iRowsOut, iColsOut, (int *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) SWIGTYPE * {
  createPointer(iVarOut, (void *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) SWIGTYPE {
  createPointer(iVarOut, (void *)&$result);
  LhsVar(iOutNum) = iVarOut;
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
  double *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_matrix || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(piAddrVar, &iRows, &iCols, (double **)&_piData);
  $1 = ($1_ltype)*_piData;
}

%typemap(varin,noblock=1) char {   
  char *_pstStrings;
  int _piLength;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
    
  if (getVarType(piAddrVar) != sci_strings || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfString(piAddrVar, &iRows, &iCols,&_piLength, (char **)&_pstStrings);
  $1 = ($1_ltype)*_pstStrings;
}

%typemap(varin,noblock=1) char * {
  char *_pstStrings;
  int _piLength;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_strings || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfString(piAddrVar, &iRows, &iCols, &_piLength, NULL);
  _pstStrings = (char *)malloc(sizeof(char) * _piLength + 1);
  getMatrixOfString(piAddrVar, &iRows, &iCols, &_piLength, (char **)&_pstStrings);
  $1 = ($1_ltype)strdup(_pstStrings);
  free(_pstStrings);
}

%typemap(varin,noblock=1) char [ANY] {
  char *_pstStrings;
  int _piLength;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_strings || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  
  getMatrixOfString(piAddrVar, &iRows, &iCols, &_piLength, NULL);
  _pstStrings = (char *)malloc(sizeof(char) * _piLength);
  getMatrixOfString(piAddrVar, &iRows, &iCols, &_piLength, (char **)&_pstStrings);
  strcpy($1, _pstStrings);
  free(_pstStrings);
}

%typemap(varin,noblock=1) signed char [ANY] {
  char *_piData;
  size_t ii = 0;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger8(piAddrVar, &iRows, &iCols, (char **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) unsigned char [ANY] {
  unsigned char *_piData;
  size_t ii = 0;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger8(piAddrVar, &iRows, &iCols, (unsigned char **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) short [ANY] {
  short *_piData;
  size_t ii = 0;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger16(piAddrVar, &iRows, &iCols, (short **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) unsigned short [ANY] {
  unsigned short *_piData;
  size_t ii = 0;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger16(piAddrVar, &iRows, &iCols, (unsigned short **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) int [ANY],
	                  long [ANY] {
  int *_piData;
  size_t ii = 0;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger32(piAddrVar, &iRows, &iCols, (int **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) unsigned int [ANY],
	                  unsigned long [ANY] {
  unsigned int *_piData;
  size_t ii = 0;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger32(piAddrVar, &iRows, &iCols, (unsigned int **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) double [ANY],
                          float [ANY] {
  double *_piData;
  size_t ii = 0;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_matrix || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(piAddrVar, &iRows, &iCols, (double **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++){
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) long long [ANY] {
  int *_piData;
  size_t ii = 0;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger64(piAddrVar, &iRows, &iCols, (long long **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) unsigned long long [ANY] {
  int *_piData;
  size_t ii = 0;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger64(piAddrVar, &iRows, &iCols, (unsigned long long **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++) {
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
  void *_piData = NULL;
  getVarAddressFromPosition($argnum, &piAddrVar);
  
  if (getVarType(piAddrVar) != sci_lufact_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
  getPointer(piAddrVar, (void **)&_piData);
  $1 = ($1_ltype)_piData;
}

%typemap(varin,noblock=1) char ** {
  char **_pstStrings;
  int *_piLength;
  int i;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_strings || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  
  _piLength = (int*)malloc(sizeof(int) * iRows * iCols);
  getMatrixOfString(piAddrVar, &iRows, &iCols, _piLength, NULL);
  
  _pstStrings = (char**)malloc(iRows * iCols * sizeof(char*));
  for(i = 0; i < iRows * iCols; i++) {
    _pstStrings[i] = (char*)malloc((_piLength[i] + 1) * sizeof(char));
  }
  getMatrixOfString(piAddrVar, &iRows, &iCols, _piLength, (char **)_pstStrings);
  
  $1 = _pstStrings;
}

/* Arrays */
%typemap(varin,noblock=1) signed char [ANY][ANY] {
  char *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger8(piAddrVar, &iRows, &iCols, (char **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(varin,noblock=1) unsigned char [ANY][ANY] {
  unsigned char *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger8(piAddrVar, &iRows, &iCols, (unsigned char **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(varin,noblock=1) short [ANY][ANY] {
  short *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger16(piAddrVar, &iRows, &iCols, (short **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(varin,noblock=1) unsigned short [ANY][ANY] {
  unsigned short *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger16(piAddrVar, &iRows, &iCols, (unsigned short **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(varin,noblock=1) int [ANY][ANY], 
                          long [ANY][ANY] {
  int *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger32(piAddrVar, &iRows, &iCols, (int **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(varin,noblock=1) unsigned int [ANY][ANY],
                          unsigned long [ANY][ANY] {
  unsigned int *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger32(piAddrVar, &iRows, &iCols, (unsigned int **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(varin,noblock=1) double [ANY][ANY],
                          float [ANY][ANY] {
  double *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_matrix || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(piAddrVar, &iRows, &iCols, (double **)&_piData);
 
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(varin,noblock=1) long long [ANY][ANY] {
  long long *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger64(piAddrVar, &iRows, &iCols, (long long **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(varin,noblock=1) unsigned long long [ANY][ANY] {
  unsigned long long *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger64(piAddrVar, &iRows, &iCols, (unsigned long long **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(varin,noblock=1) enum SWIGTYPE {
  int *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger32(piAddrVar, &iRows, &iCols, (int **)&_piData);
  $1 = ($1_ltype)*_piData;
}
%typemap(varin,noblock=1) SWIGTYPE * {
  void *_piData = NULL;
  getVarAddressFromPosition($argnum, &piAddrVar);
  
  if (getVarType(piAddrVar) != sci_lufact_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
  getPointer(piAddrVar, (void **)&_piData);
  $1 = ($1_ltype)_piData;
}

%typemap(varin,noblock=1) SWIGTYPE [ANY] {
  void *_piData = NULL;
  size_t ii;
  getVarAddressFromPosition($argnum, &piAddrVar);
  
  if (getVarType(piAddrVar) != sci_lufact_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
  getPointer(piAddrVar, (void **)&_piData);
  for(ii = 0; ii < $1_dim0; ii++){
    $1[ii] = (($1_ltype)_piData)[ii];
  }
}

%typemap(varin,noblock=1) SWIGTYPE [ANY][ANY] {
  void *_piData = NULL;
  getVarAddressFromPosition($argnum, &piAddrVar);
  
  if (getVarType(piAddrVar) != sci_lufact_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
  getPointer(piAddrVar, (void **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = (($1_basetype *)_piData)[jj * $1_dim0+ii];
  }
}

%typemap(varin,nobloack=1) SWIGTYPE {
  void *_piData = NULL;
  getVarAddressFromPosition($argnum, &piAddrVar);
  
  if (getVarType(piAddrVar) != sci_lufact_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
  getPointer(piAddrVar, (void **)&_piData);
  $1 = *(($&1_ltype)_piData);
}

/* -----------------------------------------------------------------------------
 * --- Variable output --- 
 * ----------------------------------------------------------------------------- */
/* Basic C types */
%typemap(varout,noblock=1) signed char {
  char temp = $result;
  createMatrixOfInteger8(iVarOut, iRowsOut, iColsOut, (char *)&temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned char {
  unsigned char temp = $result;
  createMatrixOfUnsignedInteger8(iVarOut, iRowsOut, iColsOut, (unsigned char *)&temp);
  LhsVar(iOutNum) = iVarOut;

}

%typemap(varout,noblock=1) short {
  short temp = $result;
  createMatrixOfInteger16(iVarOut, iRowsOut, iColsOut, (short *)&temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned short {
  unsigned short temp = $result;
  createMatrixOfUnsignedInteger16(iVarOut, iRowsOut, iColsOut, (unsigned short *)&temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) int,
                           long {
  int temp = $result;
  createMatrixOfInteger32(iVarOut, iRowsOut, iColsOut, (int *)&temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned int,
                           unsigned long {
  unsigned int temp = $result;
  createMatrixOfUnsignedInteger32(iVarOut, iRowsOut, iColsOut, (unsigned int *)&temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) double,
                           float {
  double temp = $result;
  createMatrixOfDouble(iVarOut, iRowsOut, iColsOut, (double *)&temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) long long {
  long long temp = $result;
  createMatrixOfInteger64(iVarOut, iRowsOut, iColsOut, (long long *)&temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned long long {
  unsigned long long temp = $result;
  createMatrixOfUnsignedInteger64(iVarOut, iRowsOut, iColsOut, (unsigned long long *)&temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) char {
  char *temp = (char *)malloc(sizeof($result) + 1);
  *temp = $result;
  *(temp+1) = '\0';
  createMatrixOfString(iVarOut, iRowsOut, iColsOut, (char **)&temp);
  LhsVar(iOutNum) = iVarOut;
  free(temp);
}

%typemap(varout,noblock=1) char * {
  char *temp = $result;
  createMatrixOfString(iVarOut, iRowsOut, iColsOut, (char **)&temp);
  LhsVar(iOutNum) = iVarOut;
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
  createPointer(iVarOut, (void *)$result);
  LhsVar(iOutNum) = iVarOut;
}

/* Arrays */
%typemap(varout,noblock=1) char [ANY] {
  char **pstData = NULL;
  pstData = (char **)malloc(sizeof(char *));
  pstData[0] = $result;
  createMatrixOfString(iVarOut, iRowsOut, iColsOut, (char **)pstData);
  LhsVar(iOutNum) = iVarOut;
   
}

%typemap(varout,noblock=1) signed char [ANY] {
  createMatrixOfInteger8(iVarOut, 1, $1_dim0, (char *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned char [ANY] {
  createMatrixOfUnsignedInteger8(iVarOut, 1, $1_dim0, (unsigned char *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) short [ANY] {
  createMatrixOfInteger16(iVarOut, 1, $1_dim0, (short *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned short [ANY] {
  createMatrixOfUnsignedInteger16(iVarOut, 1, $1_dim0, (unsigned short *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) int [ANY],
                           long [ANY] {
  createMatrixOfInteger32(iVarOut, 1, $1_dim0, (int *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned int [ANY],
                           unsigned long [ANY] {
  createMatrixOfUnsignedInteger32(iVarOut, 1, $1_dim0, (unsigned int *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) double [ANY] {
  createMatrixOfDouble(iVarOut, 1, $1_dim0, (double *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) float [ANY] {
  createMatrixOfDouble(iVarOut, 1, $1_dim0, (double *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) long long [ANY] {
  createMatrixOfInteger64(iVarOut, 1, $1_dim0, (long long *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned long long [ANY] {
  createMatrixOfUnsignedInteger64(iVarOut, 1, $1_dim0, (unsigned long long *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) char ** {
  char **pstData = NULL;
  pstData = (char **)malloc(iRowsOut * iColsOut * sizeof(char*));
  pstData = $result;
  createMatrixOfString(iVarOut, iRowsOut, iColsOut, (char **)pstData);
  LhsVar(iOutNum) = iVarOut;
}

/* Enums */
%typemap(varout,noblock=1) enum SWIGTYPE {
  createMatrixOfInteger32(iVarOut, iRowsOut, iColsOut, (int *)&temp);
  LhsVar(iOutNum) = iVarOut;
}

/* Other types */
%typemap(varout,noblock=1) SWIGTYPE * {
  createPointer(iVarOut, (void *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) SWIGTYPE {
  createPointer(iVarOut, (void *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

/* ------------------------------------------------------------
 * --- Typecheck typemaps ---
 * ------------------------------------------------------------ */
/* Basic C types */
%typecheck(SWIG_TYPECHECK_CHAR) char {
  int *piAddrVar;
  getVarAddressFromPosition($argnum, &piAddrVar);
  $1 = (getVarType(piAddrVar) == sci_strings) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INT8) signed char {
  int *piAddrVar;
  getVarAddressFromPosition($argnum, &piAddrVar);
  $1 = (getVarType(piAddrVar) == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_UINT8) unsigned char {
  int *piAddrVar;
  getVarAddressFromPosition($argnum, &piAddrVar);
  $1 = (getVarType(piAddrVar) == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INT16) short {
  int *piAddrVar;
  getVarAddressFromPosition($argnum, &piAddrVar);
  $1 = (getVarType(piAddrVar) == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_UINT16) unsigned short {
  int *piAddrVar;
  getVarAddressFromPosition($argnum, &piAddrVar);
  $1 = (getVarType(piAddrVar) == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INT32) int, 
                                 long {
  int *piAddrVar;
  getVarAddressFromPosition($argnum, &piAddrVar);
  $1 = (getVarType(piAddrVar) == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_UINT32) unsigned int,
                                  unsigned long {
  int *piAddrVar;
  getVarAddressFromPosition($argnum, &piAddrVar);
  $1 = (getVarType(piAddrVar) == sci_matrix) ? 1 : 0;
}


%typecheck(SWIG_TYPECHECK_DOUBLE) double {
  int *piAddrVar;
  getVarAddressFromPosition($argnum, &piAddrVar);
  $1 = (getVarType(piAddrVar) == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_FLOAT) float {
  int *piAddrVar;
  getVarAddressFromPosition($argnum, &piAddrVar);
  $1 = (getVarType(piAddrVar) == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_STRING) char * {
  int *piAddrVar;
  getVarAddressFromPosition($argnum, &piAddrVar);
  $1 = (getVarType(piAddrVar) == sci_strings) ? 1 : 0;
}

/* Arrays */
%typecheck(SWIG_TYPECHECK_CHAR_ARRAY) char [ANY] {
  int *piAddrVar;
  getVarAddressFromPosition($argnum, &piAddrVar);
  $1 = (getVarType(piAddrVar) == sci_strings) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INT8_ARRAY) signed char [ANY] {
  int *piAddrVar;
  getVarAddressFromPosition($argnum, &piAddrVar);
  $1 = (getVarType(piAddrVar) == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INT16_ARRAY) unsigned char [ANY],
                                       short [ANY] {
  int *piAddrVar;
  getVarAddressFromPosition($argnum, &piAddrVar);
  $1 = (getVarType(piAddrVar) == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INT32_ARRAY) unsigned short [ANY],
                                       int [ANY],
                                       long [ANY] {
  int *piAddrVar;
  getVarAddressFromPosition($argnum, &piAddrVar);
  $1 = (getVarType(piAddrVar) == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INT64_ARRAY) unsigned int [ANY],
                                        unsigned long [ANY] {
  int *piAddrVar;
  getVarAddressFromPosition($argnum, &piAddrVar);
  $1 = (getVarType(piAddrVar) == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_DOUBLE_ARRAY) double [ANY]{
  int *piAddrVar;
  getVarAddressFromPosition($argnum, &piAddrVar);
  $1 = (getVarType(piAddrVar) == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_FLOAT_ARRAY) float [ANY]{
  int *piAddrVar;
  getVarAddressFromPosition($argnum, &piAddrVar);
  $1 = (getVarType(piAddrVar) == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_STRING_ARRAY) char ** {
  int *piAddrVar;
  getVarAddressFromPosition($argnum, &piAddrVar);
  $1 = (getVarType(piAddrVar) == sci_strings) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE * {
  int *piAddrVar;
  getVarAddressFromPosition($argnum, &piAddrVar);
  $1 = (getVarType(piAddrVar) == sci_lufact_pointer) ? 1 : 0;
}

/* ------------------------------------------------------------
 *  size_t mapped as int
 * ------------------------------------------------------------ */

%apply int { size_t };
