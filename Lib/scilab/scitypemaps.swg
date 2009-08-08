
// Include fundamental fragemt definitions
%include <typemaps/fragments.swg>

// Look for user fragments file.
%include <scifragments.swg>

// Scilab fragments for primitive types
%include <sciprimtypes.swg>

// Include the unified typemap library
//%include <typemaps/swigtypemaps.swg>

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
	     double (int iRows, int iCols) {
  int *piAddrVar;
  double *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_matrix || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(piAddrVar, &iRows, &iCols,  &_piData);
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
  getMatrixOfString(piAddrVar, &iRows, &iCols,&_piLength, &_pstStrings);
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
             float * {
  int *piAddrVar;
  void *_piData = NULL;
  getVarAddressFromPosition($argnum, &piAddrVar);
  
  if (getVarType(piAddrVar) != sci_lufact_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
  getPointer(piAddrVar, &_piData);
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
  getMatrixOfString(piAddrVar, &iRows, &iCols,&_piLength, &_pstStrings);
  $1 = strdup(_pstStrings);
}

%typemap(in) signed char [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  char *_piData;
  int index;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger8(piAddrVar, &iRows, &iCols,  &_piData);
  for(index = 0; index < $1_dim0; index++) {
    $1[index] = ($*1_ltype)_piData[index];
  }
}

%typemap(in) short [ANY] (int iRows, int iCols),
             unsigned char [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  short *_piData;
  int index;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger16(piAddrVar, &iRows, &iCols,  &_piData);
  for(index = 0; index < $1_dim0; index++) {
    $1[index] = ($*1_ltype)_piData[index];
  }
}

%typemap(in) unsigned short [ANY] (int iRows, int iCols),
	     int [ANY] (int iRows, int iCols),
	     unsigned int [ANY] (int iRows, int iCols),
	     long [ANY] (int iRows, int iCols),
	     unsigned long [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int *_piData;
  int index;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger32(piAddrVar, &iRows, &iCols,  &_piData);
  for(index = 0; index < $1_dim0; index++) {
    $1[index] = ($*1_ltype)_piData[index];
  }
}

%typemap(in) double [ANY] (int iRows, int iCols),
             float [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  double *_piData;
  int index;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_matrix || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(piAddrVar, &iRows, &iCols,  &_piData);
  for(index = 0; index < $1_dim0; index++){
    $1[index] = ($*1_ltype)_piData[index];
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
  getMatrixOfString(piAddrVar, &iRows, &iCols,&_piLength, &_pstStrings);
  $1 = strdup(_pstStrings);
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
  getMatrixOfInteger8(piAddrVar, &iRows, &iCols,  &_piData);
  if($1 != NULL) {
    free($1);
  }
  $1 = ($1_ltype)malloc(iRows * sizeof($*1_ltype));
  size_t ii;
  for(ii = 0; ii < iRows; ii++){
    $1[ii] = ($*1_ltype)malloc(iCols * sizeof($1_basetype));
    size_t jj;
    for(jj=0; jj < iCols; jj++)
    $1[ii][jj] = ($1_basetype)_piData[jj * iRows+ii];
  }
}

%typemap(in) short [ANY][ANY] (int iRows, int iCols),
             unsigned char [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  short *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger16(piAddrVar, &iRows, &iCols,  &_piData);
  if($1 != NULL) {
    free($1);
  }
  $1 = ($1_ltype)malloc(iRows*sizeof($*1_ltype));
  size_t ii;
  for(ii = 0; ii < iRows; ii++){
    $1[ii] = ($*1_ltype)malloc(iCols * sizeof($1_basetype));
    size_t jj;
    for(jj = 0; jj < iCols; jj++)
    $1[ii][jj] = ($1_basetype)_piData[jj * iRows+ii];
  }
}

%typemap(in) unsigned short [ANY][ANY] (int iRows, int iCols),
             int [ANY][ANY] (int iRows, int iCols), 
             unsigned int [ANY][ANY] (int iRows, int iCols),
             long [ANY][ANY] (int iRows, int iCols),
             unsigned long [ANY][ANY] (int iRows, int iCols){
  int *piAddrVar;
  int *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger32(piAddrVar, &iRows, &iCols,  &_piData);
  if($1 != NULL) {
    free($1);
  }
  $1 = ($1_ltype)malloc(iRows*sizeof($*1_ltype));
  size_t ii;
  for(ii = 0; ii < iRows;ii++){
    $1[ii] = ($*1_ltype)malloc(iCols * sizeof($1_basetype));
    size_t jj;
    for(jj = 0; jj < iCols; jj++)
    $1[ii][jj] = ($1_basetype)_piData[jj * iRows+ii];
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
  getMatrixOfDouble(piAddrVar, &iRows, &iCols,  &_piData);
  if($1 != NULL) {
    free($1);
  }
  $1 = ($1_ltype)malloc(iRows * sizeof($*1_ltype));
  size_t ii;
  for(ii = 0; ii < iRows; ii++){
    $1[ii] = ($*1_ltype)malloc(iCols * sizeof($1_basetype));
    size_t jj;
    for(jj = 0; jj < iCols; jj++)
    $1[ii][jj] = ($1_basetype)_piData[jj * iRows+ii];
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
  getMatrixOfInteger32(piAddrVar, &iRows, &iCols,  &_piData);
  $1 = ($1_ltype)*_piData;
}

%typemap(in) SWIGTYPE * {
  int *piAddrVar;
  void *_piData = NULL;
  getVarAddressFromPosition($argnum, &piAddrVar);
  
  if (getVarType(piAddrVar) != sci_lufact_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
  getPointer(piAddrVar, &_piData);
  $1 = ($1_ltype)_piData;
}

%typemap(in) SWIGTYPE {
  int *piAddrVar;
  void *_piData = NULL;
  getVarAddressFromPosition($argnum, &piAddrVar);
  
  if (getVarType(piAddrVar) != sci_lufact_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
  getPointer(piAddrVar, &_piData);
  $1 = *(($&1_ltype)_piData);
}

/* -----------------------------------------------------------------------------
 * --- Output arguments --- 
 * ----------------------------------------------------------------------------- */

/* Basic C types */
%typemap(out) signed char (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfInteger8(iVarOut, iRowsOut, iColsOut, &$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) unsigned char (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfUnsignedInteger8(iVarOut, iRowsOut, iColsOut, &$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) short (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfInteger16(iVarOut, iRowsOut, iColsOut, &$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) unsigned short (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfUnsignedInteger16(iVarOut, iRowsOut, iColsOut, &$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) int (int iRowsOut, int iColsOut),
              long (int iRowsOut, int iColsOut) {
  int temp;
  temp = (int)($result);
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfInteger32(iVarOut, iRowsOut, iColsOut, &temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) unsigned int (int iRowsOut, int iColsOut),
              unsigned long (int iRowsOut, int iColsOut) {
  int temp;
  temp = (int)($result);
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfUnsignedInteger32(iVarOut, iRowsOut, iColsOut, &temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) double (int iRowsOut, int iColsOut),
              float (int iRowsOut, int iColsOut) {
  double temp;
  temp = (double)($result);
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfDouble(iVarOut, iRowsOut, iColsOut, &temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) char (int iRowsOut, int iColsOut) {
  char *temp;
  temp = (char*)&($result);
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfString(iVarOut, iRowsOut, iColsOut, &temp);
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
              float * {
  createPointer(iVarOut, (void *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(out) char *(int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfString(iVarOut, iRowsOut, iColsOut, &($result));
  LhsVar(iOutNum) = iVarOut;
}

%typemap(freearg, noblock=1) char * { 
  if ($1) free($1);  
}

%typemap(out) enum SWIGTYPE (int iRowsOut, int iColsOut) {
  int temp;
  temp = (int)($result);
  iRowsOut = 1; 
  iColsOut = 1;
  createMatrixOfInteger32(iVarOut, iRowsOut, iColsOut, &temp);
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
  getMatrixOfDouble(piAddrVar, &iRows, &iCols,  &_piData);
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
  getMatrixOfString(piAddrVar, &iRows, &iCols,&_piLength, &_pstStrings);
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
  _pstStrings = (char *)malloc(sizeof(char) * _piLength);
  getMatrixOfString(piAddrVar, &iRows, &iCols, &_piLength, &_pstStrings);
  $1 = strdup(_pstStrings);
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
  getMatrixOfString(piAddrVar, &iRows, &iCols, &_piLength, &_pstStrings);
  strcpy($1, _pstStrings);
  free(_pstStrings);
}

%typemap(varin,noblock=1) signed char [ANY] {
  char *_piData;
  int index;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger8(piAddrVar, &iRows, &iCols,  &_piData);
  for(index = 0; index < $1_dim0; index++) {
    $1[index] = ($*1_ltype)_piData[index];
  }
}

%typemap(varin,noblock=1) unsigned char [ANY] {
  short *_piData;
  int index;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger8(piAddrVar, &iRows, &iCols,  &_piData);
  for(index = 0; index < $1_dim0; index++) {
    $1[index] = ($*1_ltype)_piData[index];
  }
}

%typemap(varin,noblock=1) short [ANY] {
  short *_piData;
  int index;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger16(piAddrVar, &iRows, &iCols,  &_piData);
  for(index = 0; index < $1_dim0; index++) {
    $1[index] = ($*1_ltype)_piData[index];
  }
}

%typemap(varin,noblock=1) unsigned short [ANY] {
  short *_piData;
  int index;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger16(piAddrVar, &iRows, &iCols,  &_piData);
  for(index = 0; index < $1_dim0; index++) {
    $1[index] = ($*1_ltype)_piData[index];
  }
}

%typemap(varin,noblock=1) int [ANY],
	                  long [ANY] {
  int *_piData;
  int index;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger32(piAddrVar, &iRows, &iCols,  &_piData);
  for(index = 0; index < $1_dim0; index++) {
    $1[index] = ($*1_ltype)_piData[index];
  }
}

%typemap(varin,noblock=1) unsigned int [ANY],
	                  unsigned long [ANY] {
  int *_piData;
  int index;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfUnsignedInteger32(piAddrVar, &iRows, &iCols,  &_piData);
  for(index = 0; index < $1_dim0; index++) {
    $1[index] = ($*1_ltype)_piData[index];
  }
}

%typemap(varin,noblock=1) double [ANY],
                          float [ANY] {
  double *_piData;
  int index;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_matrix || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(piAddrVar, &iRows, &iCols,  &_piData);
  for(index = 0; index < $1_dim0; index++){
    $1[index] = ($*1_ltype)_piData[index];
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
                          float * {
  void *_piData = NULL;
  getVarAddressFromPosition($argnum, &piAddrVar);
  
  if (getVarType(piAddrVar) != sci_lufact_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
  getPointer(piAddrVar, &_piData);
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
  getMatrixOfString(piAddrVar, &iRows, &iCols, _piLength, _pstStrings);
  
  $1 = _pstStrings;
}

%typemap(varin,noblock=1) enum SWIGTYPE {
  int *_piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger32(piAddrVar, &iRows, &iCols,  &_piData);
  $1 = ($1_ltype)*_piData;
}
%typemap(varin,noblock=1) SWIGTYPE * {
  void *_piData = NULL;
  getVarAddressFromPosition($argnum, &piAddrVar);
  
  if (getVarType(piAddrVar) != sci_lufact_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
  getPointer(piAddrVar, &_piData);
  $1 = ($1_ltype)_piData;
}

%typemap(varin,noblock=1) SWIGTYPE [ANY] {
  void *_piData = NULL;
  int index;
  getVarAddressFromPosition($argnum, &piAddrVar);
  
  if (getVarType(piAddrVar) != sci_lufact_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
  getPointer(piAddrVar, &_piData);
  for(index = 0; index < $1_dim0; index++){
    $1[index] = (($1_ltype)_piData)[index];
  }
}

%typemap(varin,nobloack=1) SWIGTYPE {
  void *_piData = NULL;
  getVarAddressFromPosition($argnum, &piAddrVar);
  
  if (getVarType(piAddrVar) != sci_lufact_pointer) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Pointer expected.\n"), fname, $argnum);
  }
  getPointer(piAddrVar, &_piData);
  $1 = *(($&1_ltype)_piData);
}

/* -----------------------------------------------------------------------------
 * --- Variable output --- 
 * ----------------------------------------------------------------------------- */
/* Basic C types */
%typemap(varout,noblock=1) signed char {
  signed char temp = $result;
  createMatrixOfInteger8(iVarOut, iRowsOut, iColsOut, &temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned char {
  unsigned char temp = $result;
  createMatrixOfUnsignedInteger8(iVarOut, iRowsOut, iColsOut, &temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) short {
  short temp = $result;
  createMatrixOfInteger16(iVarOut, iRowsOut, iColsOut, &temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned short {
  unsigned short temp = $result;
  createMatrixOfUnsignedInteger16(iVarOut, iRowsOut, iColsOut, &temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) int,
                           long {
  int temp = $result;
  createMatrixOfInteger32(iVarOut, iRowsOut, iColsOut, &temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned int,
                           unsigned long {
  unsigned int temp = $result;
  createMatrixOfUnsignedInteger32(iVarOut, iRowsOut, iColsOut, &temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) double {
  double temp = $result;
  createMatrixOfDouble(iVarOut, iRowsOut, iColsOut, &temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) float {
  double temp = $result;
  createMatrixOfDouble(iVarOut, iRowsOut, iColsOut, &temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) long long {
  long long temp = $result;
  createMatrixOfInteger64(iVarOut, iRowsOut, iColsOut, &temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) unsigned long long {
  unsigned long long temp = $result;
  createMatrixOfUnsignedInteger64(iVarOut, iRowsOut, iColsOut, &temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) char {
  char *temp = (char *)malloc(sizeof($result) + 1);
  *temp = $result;
  *(temp+1) = '\0';
  createMatrixOfString(iVarOut, iRowsOut, iColsOut, &temp);
  LhsVar(iOutNum) = iVarOut;
  free(temp);
}

%typemap(varout,noblock=1) char * {
  char *temp = $result;
  createMatrixOfString(iVarOut, iRowsOut, iColsOut, &temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) signed char *,
                           short *,
                           unsigned char *,
                           unsigned short *,
	                   int *,
	                   unsigned int *,
	                   long *,
	                   unsigned long *,
                           double *,
                           float * {
  createPointer(iVarOut, (void *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) char [ANY] {
  char **pstData = NULL;
  pstData = (char **)malloc(sizeof(char *));
  pstData[0] = $result;
  createMatrixOfString(iVarOut, iRowsOut, iColsOut, pstData);
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

%typemap(varout,noblock=1) char ** {
  char **pstData = NULL;
  pstData = (char **)malloc(iRowsOut * iColsOut * sizeof(char*));
  pstData = $result;
  createMatrixOfString(iVarOut, iRowsOut, iColsOut, pstData);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) enum SWIGTYPE {
  int temp = $result;
  createMatrixOfInteger32(iVarOut, iRowsOut, iColsOut, &temp);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) SWIGTYPE * {
  createPointer(iVarOut, (void *)$result);
  LhsVar(iOutNum) = iVarOut;
}

%typemap(varout,noblock=1) SWIGTYPE {
  createPointer(iVarOut, (void *)&$result);
  LhsVar(iOutNum) = iVarOut;
}
  
/* ------------------------------------------------------------
 *  size_t mapped as int
 * ------------------------------------------------------------ */

%apply int { size_t };
