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
  int typearg;
  double *_piData;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_matrix || iRows != 1 || iCols != 1 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
  $1 = ($1_ltype)*_piData;
}

%typemap(in) char (int iRows, int iCols) {   
  int *piAddrVar;
  int typearg;
  char *_pstStrings;
  int _piLength;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
    
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_strings || iRows != 1 || iCols != 1 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols,&_piLength, (char **)&_pstStrings);
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
  int typearg;
  void *_piData = NULL;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
  getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
  $1 = ($1_ltype)_piData;
}

%typemap(in) char * (int iRows, int iCols){
  int *piAddrVar;
  int typearg;
  char *_pstStrings;
  int _piLength;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);

  getVarType(pvApiCtx, piAddrVar, &typearg);  
  if (typearg != sci_strings || iRows != 1 || iCols != 1 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, NULL);
  _pstStrings = (char *)malloc(sizeof(char) * _piLength + 1);
  getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, (char **)&_pstStrings);
  $1 = ($1_ltype)strdup(_pstStrings);
  free(_pstStrings);
}

%typemap(in) signed char [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  char *_piData;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if ( typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Array of signed char expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, (char **)&_piData);
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) unsigned char [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  unsigned char *_piData;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);

  getVarType(pvApiCtx, piAddrVar, &typearg);  
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Array of unsigned char expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned char **)&_piData);
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) short [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  short *_piData;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Array of short expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger16(pvApiCtx, piAddrVar, &iRows, &iCols, (short **)&_piData);
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) unsigned short [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  unsigned short *_piData;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Array of unsigned short expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger16(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned short **)&_piData);
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) int [ANY] (int iRows, int iCols),
	     long [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  int *_piData;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Array of int expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (int **)&_piData);
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) unsigned int [ANY] (int iRows, int iCols),
	     unsigned long [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  unsigned int *_piData;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Array of unsigned int expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned int **)&_piData);
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) double [ANY] (int iRows, int iCols),
             float [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  double *_piData;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_matrix || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Array of double expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
  for(; ii < (size_t)iCols; ii++){
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) long long [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  long long *_piData;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Array of long long expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger64(pvApiCtx, piAddrVar, &iRows, &iCols, (long long **)&_piData);
  for(; ii < (size_t)iCols; ii++){
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) unsigned long long [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  unsigned long long *_piData;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Array of unsigned long long expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger64(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned long long **)&_piData);
  for(; ii < (size_t)iCols; ii++){
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) char [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  char *_pstStrings;
  int _piLength;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_strings || iRows != 1 || iCols != 1 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Array of char expected.\n"), fname, $argnum);
  }
  getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols,&_piLength, (char **)&_pstStrings);
  $1 = ($1_ltype)strdup(_pstStrings);
}

%typemap(in) signed char [] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  char *_piData;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Array of signed char expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, (char **)&_piData);
  $1 = ($1_ltype)malloc(sizeof($*1_ltype) * iCols);
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) unsigned char [] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  unsigned char *_piData;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Array of unsigned char expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned char **)&_piData);
  $1 = ($1_ltype)malloc(sizeof($*1_ltype) * iCols);
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) short [] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  short *_piData;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Array of short expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger16(pvApiCtx, piAddrVar, &iRows, &iCols, (short **)&_piData);
  $1 = ($1_ltype)malloc(sizeof($*1_ltype) * iCols);
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) unsigned short [] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  unsigned short *_piData;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Array of unsigned short expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger16(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned short **)&_piData);
  $1 = ($1_ltype)malloc(sizeof($*1_ltype) * iCols);
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) int [] (int iRows, int iCols),
	     long [] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  int *_piData;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Array of int expected.\n"), fname, $argnum);
  }
  $1 = ($1_ltype)malloc(sizeof($*1_ltype) * iCols);
  getMatrixOfInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (int **)&_piData);
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) unsigned int [] (int iRows, int iCols),
	     unsigned long [] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  unsigned int *_piData;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Array of unsigned int expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned int **)&_piData);
  $1 = ($1_ltype)malloc(sizeof($*1_ltype) * iCols);
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) double [] (int iRows, int iCols),
             float [] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  double *_piData;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_matrix || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Array of double expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
  $1 = ($1_ltype)malloc(sizeof($*1_ltype) * iCols);
  for(; ii < (size_t)iCols; ii++){
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) long long [] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  long long *_piData;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Array of long long expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger64(pvApiCtx, piAddrVar, &iRows, &iCols, (long long **)&_piData);
  $1 = ($1_ltype)malloc(sizeof($*1_ltype) * iCols);
  for(; ii < (size_t)iCols; ii++){
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) unsigned long long [] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  unsigned long long *_piData;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Array of unsigned long long expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger64(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned long long **)&_piData);
  $1 = ($1_ltype)malloc(sizeof($*1_ltype) * iCols);
  for(; ii < (size_t)iCols; ii++){
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

/* Arrays */
%typemap(in) signed char [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  char *_piData;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Matrix of signed char expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, (char **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)iRows; ii++){
    size_t jj = 0;
    for(; jj < (size_t)iCols; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * iRows + ii];
  }
}

%typemap(in) unsigned char [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  unsigned char *_piData;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Matrix of unsigned char expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned char **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)iRows; ii++){
    size_t jj = 0;
    for(; jj < (size_t)iCols; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * iRows + ii];
  }
}

%typemap(in) short [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  short *_piData;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Matrix of short expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger16(pvApiCtx, piAddrVar, &iRows, &iCols, (short **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)iRows; ii++){
    size_t jj = 0;
    for(; jj < (size_t)iCols; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * iRows + ii];
  }
}

%typemap(in) unsigned short [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  unsigned short *_piData;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Matrix of unsigned short expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger16(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned short **)&_piData);
 
  size_t ii = 0;
  for(; ii < (size_t)iRows; ii++){
    size_t jj = 0;
    for(; jj < (size_t)iCols; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * iRows + ii];
  }
}

%typemap(in) int [ANY][ANY] (int iRows, int iCols), 
             long [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int *_piData;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Matrix of int expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (int **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)iRows; ii++){
    size_t jj = 0;
    for(; jj < (size_t)iCols; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * iRows + ii];
  }
}

%typemap(in) unsigned int [ANY][ANY] (int iRows, int iCols), 
             unsigned long [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  unsigned int *_piData;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Matrix of unsigned int expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned int **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)iRows; ii++){
    size_t jj = 0;
    for(; jj < (size_t)iCols; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * iRows + ii];
  }
}

%typemap(in) double [ANY][ANY] (int iRows, int iCols),
             float [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  double *_piData;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_matrix || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Matrix of double expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)iRows; ii++){
    size_t jj = 0;
    for(; jj < (size_t)iCols; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * iRows + ii];
  }
}

%typemap(in) long long [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  long long *_piData;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Matrix of long long expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger64(pvApiCtx, piAddrVar, &iRows, &iCols, (long long **)&_piData);

  size_t ii = 0;
  for(; ii < (size_t)iRows; ii++){
    size_t jj = 0;
    for(; jj < (size_t)iCols; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * iRows + ii];
  }
}

%typemap(in) unsigned long long [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  unsigned long long *_piData;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Matrix of unsigned long long expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger64(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned long long **)&_piData);

  size_t ii = 0;
  for(; ii < (size_t)iRows; ii++){
    size_t jj = 0;
    for(; jj < (size_t)iCols; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * iRows + ii];
  }
}

%typemap(in) enum SWIGTYPE (int iRows, int iCols) {
  int *piAddrVar;
  int typearg;
  int *_piData;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || iRows != 1 || iCols != 1 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (int **)&_piData);
  $1 = ($1_ltype)*_piData;
}

%typemap(in) SWIGTYPE *,
             SWIGTYPE [] {
  int *piAddrVar;
  int typearg;
  void *_piData = NULL;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
  getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
  $1 = ($1_ltype)_piData;
}

%typemap(in) SWIGTYPE {
  int *piAddrVar;
  int typearg;
  void *_piData = NULL;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
  getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
  $1 = *(($&1_ltype)_piData);
}

/* -----------------------------------------------------------------------------
 * --- Output arguments --- 
 * ----------------------------------------------------------------------------- */

/* Basic C types */
%typemap(out) signed char (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfInteger8(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) unsigned char (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfUnsignedInteger8(pvApiCtx, iVarOut, iRowsOut, iColsOut, (unsigned char *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) short (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfInteger16(pvApiCtx, iVarOut, iRowsOut, iColsOut, (short *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) unsigned short (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfUnsignedInteger16(pvApiCtx, iVarOut, iRowsOut, iColsOut, (unsigned short *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) int (int iRowsOut, int iColsOut),
              long (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfInteger32(pvApiCtx, iVarOut, iRowsOut, iColsOut, (int *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) unsigned int (int iRowsOut, int iColsOut),
              unsigned long (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfUnsignedInteger32(pvApiCtx, iVarOut, iRowsOut, iColsOut, (unsigned int *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) double (int iRowsOut, int iColsOut),
              float (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfDouble(pvApiCtx, iVarOut, iRowsOut, iColsOut, (double *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) long long (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfInteger64(pvApiCtx, iVarOut, iRowsOut, iColsOut, (long long *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) unsigned long long (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfUnsignedInteger64(pvApiCtx, iVarOut, iRowsOut, iColsOut, (unsigned long long *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) char (int iRowsOut, int iColsOut) {
  char *temp;
  temp = (char*)&($result);
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfString(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char **)&temp);
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
  createPointer(pvApiCtx, iVarOut, (void *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) char * (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfString(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char **)&($result));
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) enum SWIGTYPE (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfInteger32(pvApiCtx, iVarOut, iRowsOut, iColsOut, (int *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) SWIGTYPE * {
  createPointer(pvApiCtx, iVarOut, (void *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) SWIGTYPE {
  createPointer(pvApiCtx, iVarOut, (void *)&$result);
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
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_matrix || iRows != 1 || iCols != 1 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
  $1 = ($1_ltype)*_piData;
}

%typemap(varin,noblock=1) char {   
  char *_pstStrings;
  int typearg;
  int _piLength;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
    
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_strings || iRows != 1 || iCols != 1 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols,&_piLength, (char **)&_pstStrings);
  $1 = ($1_ltype)*_pstStrings;
}

%typemap(varin,noblock=1) char * {
  char *_pstStrings;
  int typearg;
  int _piLength;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
    if (typearg != sci_strings || iRows != 1 || iCols != 1 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, NULL);
  _pstStrings = (char *)malloc(sizeof(char) * _piLength + 1);
  getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, (char **)&_pstStrings);
  $1 = ($1_ltype)strdup(_pstStrings);
  free(_pstStrings);
}

%typemap(varin,noblock=1) char [ANY] {
  char *_pstStrings;
  int typearg;
  int _piLength;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_strings || iRows != 1 || iCols != 1 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  
  getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, NULL);
  _pstStrings = (char *)malloc(sizeof(char) * _piLength);
  getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, (char **)&_pstStrings);
  strcpy($1, _pstStrings);
  free(_pstStrings);
}

%typemap(varin,noblock=1) signed char [ANY] {
  char *_piData;
  int typearg;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || iRows != 1 || iCols != $1_dim0 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type or dimensions for input argument #%d: Array of signed char expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, (char **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) unsigned char [ANY] {
  unsigned char *_piData;
  int typearg;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || iRows != 1 || iCols != $1_dim0 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type or dimensions for input argument #%d: Array of unsigned char expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned char **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) short [ANY] {
  short *_piData;
  int typearg;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || iRows != 1 || iCols != $1_dim0 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type or dimensions for input argument #%d: Array of short expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger16(pvApiCtx, piAddrVar, &iRows, &iCols, (short **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) unsigned short [ANY] {
  unsigned short *_piData;
  int typearg;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || iRows != 1 || iCols != $1_dim0 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type or dimensions for input argument #%d: Array of unsigned short expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger16(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned short **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) int [ANY],
	                  long [ANY] {
  int *_piData;
  int typearg;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || iRows != 1 || iCols != $1_dim0 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type or dimensions for input argument #%d: Array of int expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (int **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) unsigned int [ANY],
	                  unsigned long [ANY] {
  unsigned int *_piData;
  int typearg;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || iRows != 1 || iCols != $1_dim0 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type or dimensions for input argument #%d: Array of unsigned int expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned int **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) double [ANY],
                          float [ANY] {
  double *_piData;
  int typearg;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_matrix || iRows != 1 || iCols != $1_dim0 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type or dimensions for input argument #%d: Array of double expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++){
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) long long [ANY] {
  int *_piData;
  int typearg;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || iRows != 1 || iCols != $1_dim0 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type or dimensions for input argument #%d: Array of long long expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger64(pvApiCtx, piAddrVar, &iRows, &iCols, (long long **)&_piData);
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) unsigned long long [ANY] {
  int *_piData;
  int typearg;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || iRows != 1 || iCols != $1_dim0 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type or dimensions for input argument #%d: Array of unsigned long long expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger64(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned long long **)&_piData);
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
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
  getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
  $1 = ($1_ltype)_piData;
}

%typemap(varin,noblock=1) char ** {
  char **_pstStrings;
  int *_piLength;
  int typearg;
  int i;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_strings || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Array of string expected.\n"), fname, $argnum);
  }
  
  _piLength = (int*)malloc(sizeof(int) * iRows * iCols);
  getMatrixOfString(pvApiCtxpiAddrVar, &iRows, &iCols, _piLength, NULL);
  
  _pstStrings = (char**)malloc(iRows * iCols * sizeof(char*));
  for(i = 0; i < iRows * iCols; i++) {
    _pstStrings[i] = (char*)malloc((_piLength[i] + 1) * sizeof(char));
  }
  getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, _piLength, (char **)_pstStrings);
  
  $1 = _pstStrings;
}

/* Arrays */
%typemap(varin,noblock=1) signed char [ANY][ANY] {
  char *_piData;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || iRows != $1_dim0 || iCols != $1_dim1 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type or dimensions for input argument #%d: Matrix of signed char expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, (char **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(varin,noblock=1) unsigned char [ANY][ANY] {
  unsigned char *_piData;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || iRows != $1_dim0 || iCols != $1_dim1 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type or dimensions for input argument #%d: Matrix of unsigned char expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned char **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(varin,noblock=1) short [ANY][ANY] {
  short *_piData;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || iRows != $1_dim0 || iCols != $1_dim1 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type or dimensions for input argument #%d: Matrix of short expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger16(pvApiCtx, piAddrVar, &iRows, &iCols, (short **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(varin,noblock=1) unsigned short [ANY][ANY] {
  unsigned short *_piData;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || iRows != $1_dim0 || iCols != $1_dim1 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type or dimensions for input argument #%d: Matrix of unsigned short expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger16(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned short **)&_piData);
  
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
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || iRows != $1_dim0 || iCols != $1_dim1 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type or dimensions for input argument #%d: Matrix of int expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (int **)&_piData);
  
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
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || iRows != $1_dim0 || iCols != $1_dim1 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type or dimensions for input argument #%d: Matrix of unsigned int expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned int **)&_piData);
  
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
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_matrix || iRows != $1_dim0 || iCols != $1_dim1 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type or dimensions for input argument #%d: Matrix of double expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
 
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(varin,noblock=1) long long [ANY][ANY] {
  long long *_piData;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || iRows != $1_dim0 || iCols != $1_dim1 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type or dimensions for input argument #%d: Matrix of long long expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger64(pvApiCtx, piAddrVar, &iRows, &iCols, (long long **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(varin,noblock=1) unsigned long long [ANY][ANY] {
  unsigned long long *_piData;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || iRows != $1_dim0 || iCols != $1_dim1 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type or dimensions for input argument #%d: Matrix of unsigned long long expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger64(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned long long **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(varin,noblock=1) enum SWIGTYPE {
  int *_piData;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarDimension(pvApiCtx, piAddrVar, &iRows, &iCols);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_ints || iRows != 1 || iCols != 1 || isVarComplex(pvApiCtx, piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (int **)&_piData);
  $1 = ($1_ltype)*_piData;
}
%typemap(varin,noblock=1) SWIGTYPE * {
  void *_piData = NULL;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
  getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
  $1 = ($1_ltype)_piData;
}

%typemap(varin,noblock=1) SWIGTYPE [ANY] {
  void *_piData = NULL;
  int typearg;
  size_t ii;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
/* TODO: change for a getmatrixofXXXXXXxx */
  getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
  for(ii = 0; ii < $1_dim0; ii++){
    $1[ii] = (($1_ltype)_piData)[ii];
  }
}

%typemap(varin,noblock=1) SWIGTYPE [ANY][ANY] {
  void *_piData = NULL;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
/* TODO: change for a getmatrixofXXXXXXxx */
  getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
  
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++) { /* Fill the two dim array. Note that a Scilab matrix is stored as a flat matrix by columns */
      	  $1[ii][jj] = (($1_basetype *)_piData)[jj * $1_dim0+ii];
	  }
  }
}

%typemap(varin,nobloack=1) SWIGTYPE {
  void *_piData = NULL;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  
  getVarType(pvApiCtx, piAddrVar, &typearg);
  if (typearg != sci_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
/* TODO: change for a getmatrixofXXXXXXxx */
  getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
  $1 = *(($&1_ltype)_piData);
}

/* -----------------------------------------------------------------------------
 * --- Variable output --- 
 * ----------------------------------------------------------------------------- */
/* Basic C types */
%typemap(varout,noblock=1) signed char {
  char temp = $result;
  createMatrixOfInteger8(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char *)&temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned char {
  unsigned char temp = $result;
  createMatrixOfUnsignedInteger8(pvApiCtx, iVarOut, iRowsOut, iColsOut, (unsigned char *)&temp);
  LhsVar(iOutNum) = iVarOut;

}

%typemap(varout,noblock=1) short {
  short temp = $result;
  createMatrixOfInteger16(pvApiCtx, iVarOut, iRowsOut, iColsOut, (short *)&temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned short {
  unsigned short temp = $result;
  createMatrixOfUnsignedInteger16(pvApiCtx, iVarOut, iRowsOut, iColsOut, (unsigned short *)&temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) int,
                           long {
  int temp = $result;
  createMatrixOfInteger32(pvApiCtx, iVarOut, iRowsOut, iColsOut, (int *)&temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned int,
                           unsigned long {
  unsigned int temp = $result;
  createMatrixOfUnsignedInteger32(pvApiCtx, iVarOut, iRowsOut, iColsOut, (unsigned int *)&temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) double,
                           float {
  double temp = $result;
  createMatrixOfDouble(pvApiCtx, iVarOut, iRowsOut, iColsOut, (double *)&temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) long long {
  long long temp = $result;
  createMatrixOfInteger64(pvApiCtx, iVarOut, iRowsOut, iColsOut, (long long *)&temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned long long {
  unsigned long long temp = $result;
  createMatrixOfUnsignedInteger64(pvApiCtx, iVarOut, iRowsOut, iColsOut, (unsigned long long *)&temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) char {
  char *temp = (char *)malloc(sizeof($result) + 1);
  *temp = $result;
  *(temp+1) = '\0';
  createMatrixOfString(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char **)&temp);
  LhsVar(iOutNum) = iVarOut;
  free(temp);
}

%typemap(varout,noblock=1) char * {
  char *temp = $result;
  createMatrixOfString(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char **)&temp);
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
  createPointer(pvApiCtx, iVarOut, (void *)$result);
  LhsVar(iOutNum) = iVarOut;
}

/* Arrays */
%typemap(varout,noblock=1) char [ANY] {
  char **pstData = NULL;
  pstData = (char **)malloc(sizeof(char *));
  pstData[0] = $result;
  createMatrixOfString(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char **)pstData);
  LhsVar(iOutNum) = iVarOut;
   
}

%typemap(varout,noblock=1) signed char [ANY] {
  createMatrixOfInteger8(pvApiCtx, iVarOut, 1, $1_dim0, (char *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned char [ANY] {
  createMatrixOfUnsignedInteger8(pvApiCtx, iVarOut, 1, $1_dim0, (unsigned char *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) short [ANY] {
  createMatrixOfInteger16(pvApiCtx, iVarOut, 1, $1_dim0, (short *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned short [ANY] {
  createMatrixOfUnsignedInteger16(pvApiCtx, iVarOut, 1, $1_dim0, (unsigned short *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) int [ANY],
                           long [ANY] {
  createMatrixOfInteger32(pvApiCtx, iVarOut, 1, $1_dim0, (int *)$result); // Celu ci
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned int [ANY],
                           unsigned long [ANY] {
  createMatrixOfUnsignedInteger32(pvApiCtx, iVarOut, 1, $1_dim0, (unsigned int *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) double [ANY] {
  createMatrixOfDouble(pvApiCtx, iVarOut, 1, $1_dim0, (double *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) float [ANY] {
  createMatrixOfDouble(pvApiCtx, iVarOut, 1, $1_dim0, (double *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) long long [ANY] {
  createMatrixOfInteger64(pvApiCtx, iVarOut, 1, $1_dim0, (long long *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned long long [ANY] {
  createMatrixOfUnsignedInteger64(pvApiCtx, iVarOut, 1, $1_dim0, (unsigned long long *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) char ** {
  char **pstData = NULL;
  pstData = (char **)malloc(iRowsOut * iColsOut * sizeof(char*));
  pstData = $result;
  createMatrixOfString(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char **)pstData);
  LhsVar(iOutNum) = iVarOut;
}


%typemap(varout,noblock=1) signed char [ANY][ANY],
                           char [ANY][ANY]{
  createMatrixOfInteger8(pvApiCtx, iVarOut, $1_dim0, $1_dim1, (char *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned char [ANY][ANY] {
  createMatrixOfUnsignedInteger8(pvApiCtx, iVarOut, $1_dim0, $1_dim1, (unsigned char *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) short [ANY][ANY] {
  createMatrixOfInteger16(pvApiCtx, iVarOut, $1_dim0, $1_dim1, (short *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned short [ANY][ANY] {
  createMatrixOfUnsignedInteger16(pvApiCtx, iVarOut, $1_dim0, $1_dim1, (unsigned short *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) int [ANY][ANY],
                           long [ANY][ANY] {
  createMatrixOfInteger32(pvApiCtx, iVarOut, $1_dim0, $1_dim1, (int *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned int [ANY][ANY],
                           unsigned long [ANY][ANY] {
  createMatrixOfUnsignedInteger32(pvApiCtx, iVarOut, $1_dim0, $1_dim1, (unsigned int *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) double [ANY][ANY] {
  createMatrixOfDouble(pvApiCtx, iVarOut, $1_dim0, $1_dim1, (double *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) float [ANY][ANY] {
  createMatrixOfDouble(pvApiCtx, iVarOut, $1_dim0, $1_dim1, (double *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) long long [ANY][ANY] {
  createMatrixOfInteger64(pvApiCtx, iVarOut, $1_dim0, $1_dim1, (long long *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned long long [ANY][ANY] {
  createMatrixOfUnsignedInteger64(pvApiCtx, iVarOut, $1_dim0, $1_dim1, (unsigned long long *)$result);
  LhsVar(iOutNum) = iVarOut;
}


/* Enums */
%typemap(varout,noblock=1) enum SWIGTYPE {
  createMatrixOfInteger32(pvApiCtx, iVarOut, iRowsOut, iColsOut, (int *)&temp);
  LhsVar(iOutNum) = iVarOut;
}

/* Other types */
%typemap(varout,noblock=1) SWIGTYPE * {
  createPointer(pvApiCtx, iVarOut, (void *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) SWIGTYPE {
  createPointer(pvApiCtx, iVarOut, (void *)&$result);
  LhsVar(iOutNum) = iVarOut;
}

/* ------------------------------------------------------------
 * --- Typecheck typemaps ---
 * ------------------------------------------------------------ */
/* Basic C types */
%typecheck(SWIG_TYPECHECK_CHAR) char {
  int *piAddrVar;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_strings) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INT8) signed char {
  int *piAddrVar;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_UINT8) unsigned char {
  int *piAddrVar;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INT16) short {
  int *piAddrVar;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_UINT16) unsigned short {
  int *piAddrVar;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INT32) int, 
                                 long {
  int *piAddrVar;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_UINT32) unsigned int,
                                  unsigned long {
  int *piAddrVar;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}


%typecheck(SWIG_TYPECHECK_DOUBLE) double {
  int *piAddrVar;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_FLOAT) float {
  int *piAddrVar;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_STRING) char * {
  int *piAddrVar;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_strings) ? 1 : 0;
}

/* Arrays */
%typecheck(SWIG_TYPECHECK_CHAR_ARRAY) char [ANY] {
  int *piAddrVar;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_strings) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INT8_ARRAY) signed char [ANY] {
  int *piAddrVar;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INT16_ARRAY) unsigned char [ANY],
                                       short [ANY] {
  int *piAddrVar;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INT32_ARRAY) unsigned short [ANY],
                                       int [ANY],
                                       long [ANY] {
  int *piAddrVar;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INT64_ARRAY) unsigned int [ANY],
                                        unsigned long [ANY] {
  int *piAddrVar;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_DOUBLE_ARRAY) double [ANY]{
  int *piAddrVar;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_FLOAT_ARRAY) float [ANY]{
  int *piAddrVar;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_STRING_ARRAY) char ** {
  int *piAddrVar;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_strings) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE * {
  int *piAddrVar;
  int typearg;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_pointer) ? 1 : 0;
}

/* ------------------------------------------------------------
 *  size_t mapped as int
 * ------------------------------------------------------------ */

%apply int { size_t };
