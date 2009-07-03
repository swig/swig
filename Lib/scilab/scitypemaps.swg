
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
%typemap(in) signed char (int *piAddrVar, int iRows, int iCols),
	     unsigned char (int *piAddrVar, int iRows, int iCols),
	     short (int *piAddrVar, int iRows, int iCols),
	     unsigned short (int *piAddrVar, int iRows, int iCols),
	     int (int *piAddrVar, int iRows, int iCols),
	     unsigned int (int *piAddrVar, int iRows, int iCols),
	     long (int *piAddrVar, int iRows, int iCols),
	     unsigned long (int *piAddrVar, int iRows, int iCols),
	     float (int *piAddrVar, int iRows, int iCols),
	     double (int *piAddrVar, int iRows, int iCols) {
  double* _piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_matrix || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(piAddrVar, &iRows, &iCols,  &_piData);
  $1=($1_ltype)*_piData;
}

%typemap(in) char (int *piAddrVar, int iRows, int iCols) {   
  char* _pstStrings;
  int _piLength;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
    
  if (getVarType(piAddrVar) != sci_strings || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfString(piAddrVar, &iRows, &iCols,&_piLength, &_pstStrings);
  $1=($1_ltype)*_pstStrings;
}


/* Pointers */
%typemap(in) signed char *(int *piAddrVar, int iRows, int iCols) {
  char* _piData;
  int index;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger8(piAddrVar, &iRows, &iCols,  &_piData);
  $1=($1_ltype)_piData;
}

%typemap(in) short *(int *piAddrVar, int iRows, int iCols),
             unsigned char *(int *piAddrVar, int iRows, int iCols) {
  short* _piData;
  int index;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger16(piAddrVar, &iRows, &iCols,  &_piData);
  $1=($1_ltype)_piData;
}

%typemap(in) unsigned short *(int *piAddrVar, int iRows, int iCols),
	     int *(int *piAddrVar, int iRows, int iCols),
	     unsigned int *(int *piAddrVar, int iRows, int iCols),
	     long *(int *piAddrVar, int iRows, int iCols),
	     unsigned long *(int *piAddrVar, int iRows, int iCols) {
  int* _piData;
  int index;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger32(piAddrVar, &iRows, &iCols,  &_piData);
  $1=($1_ltype)_piData;
}

%typemap(in) double *(int *piAddrVar, int iRows, int iCols),
             float *(int *piAddrVar, int iRows, int iCols) {
  double* _piData;
  int index;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_matrix || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(piAddrVar, &iRows, &iCols,  &_piData);
  $1=($1_ltype)_piData;
}

%typemap(in) char *(int *piAddrVar, int iRows, int iCols){
  char* _pstStrings;
  int _piLength;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_strings || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfString(piAddrVar, &iRows, &iCols,&_piLength, &_pstStrings);
  $1=strdup(_pstStrings);
}

%typemap(in) signed char [ANY](int *piAddrVar, int iRows, int iCols) {
  char* _piData;
  int index;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger8(piAddrVar, &iRows, &iCols,  &_piData);
  if($1!=NULL) {
    free($1);
  }
  $1=($1_ltype)malloc(iRows*iCols*sizeof($*1_ltype));
  for(index=0;index<iRows*iCols;index++){
    $1[index]=($*1_ltype)_piData[index];
  }
}

%typemap(in) short [ANY](int *piAddrVar, int iRows, int iCols),
             unsigned char [ANY](int *piAddrVar, int iRows, int iCols) {
  short* _piData;
  int index;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger16(piAddrVar, &iRows, &iCols,  &_piData);
  if($1!=NULL) {
    free($1);
  }
  $1=($1_ltype)malloc(iRows*iCols*sizeof($*1_ltype));
  for(index=0;index<iRows*iCols;index++){
    $1[index]=($*1_ltype)_piData[index];
  }
}

%typemap(in) unsigned short [ANY](int *piAddrVar, int iRows, int iCols),
	     int [ANY](int *piAddrVar, int iRows, int iCols),
	     unsigned int [ANY](int *piAddrVar, int iRows, int iCols),
	     long [ANY](int *piAddrVar, int iRows, int iCols),
	     unsigned long [ANY](int *piAddrVar, int iRows, int iCols) {
  int* _piData;
  int index;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger32(piAddrVar, &iRows, &iCols,  &_piData);
  if($1!=NULL) {
    free($1);
  }
  $1=($1_ltype)malloc(iRows*iCols*sizeof($*1_ltype));
  for(index=0;index<iRows*iCols;index++){
    $1[index]=($*1_ltype)_piData[index];
  }
}

%typemap(in) double [ANY](int *piAddrVar, int iRows, int iCols),
             float [ANY](int *piAddrVar, int iRows, int iCols){
  double* _piData;
  int index;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_matrix || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(piAddrVar, &iRows, &iCols,  &_piData);
  if($1!=NULL) {
    free($1);
  }
  $1=($1_ltype)malloc(iRows*iCols*sizeof($*1_ltype));
  for(index=0;index<iRows*iCols;index++){
    $1[index]=($*1_ltype)_piData[index];
  }
}



%typemap(in) char [ANY](int *piAddrVar, int iRows, int iCols){
  char* _pstStrings;
  int _piLength;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_strings || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfString(piAddrVar, &iRows, &iCols,&_piLength, &_pstStrings);
  $1=strdup(_pstStrings);
}


/* Arrays */
%typemap(in) signed char [ANY][ANY](int *piAddrVar, int iRows, int iCols) {
  char* _piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger8(piAddrVar, &iRows, &iCols,  &_piData);
  if($1!=NULL) {
    free($1);
  }
  $1=($1_ltype)malloc(iRows*sizeof($*1_ltype));
  size_t ii;
  for(ii=0;ii<iRows;ii++){
    $1[ii]=($*1_ltype)malloc(iCols*sizeof($1_basetype));
    size_t jj;
    for(jj=0;jj<iCols;jj++)
    $1[ii][jj]=($1_basetype)_piData[jj*iRows+ii];
  }
}

%typemap(in) short [ANY][ANY](int *piAddrVar, int iRows, int iCols),
             unsigned char [ANY][ANY](int *piAddrVar, int iRows, int iCols) {
  short* _piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger16(piAddrVar, &iRows, &iCols,  &_piData);
  if($1!=NULL) {
    free($1);
  }
  $1=($1_ltype)malloc(iRows*sizeof($*1_ltype));
  size_t ii;
  for(ii=0;ii<iRows;ii++){
    $1[ii]=($*1_ltype)malloc(iCols*sizeof($1_basetype));
    size_t jj;
    for(jj=0;jj<iCols;jj++)
    $1[ii][jj]=($1_basetype)_piData[jj*iRows+ii];
  }
}

%typemap(in) unsigned short [ANY][ANY](int *piAddrVar, int iRows, int iCols),
             int [ANY][ANY](int *piAddrVar, int iRows, int iCols), 
             unsigned int [ANY][ANY](int *piAddrVar, int iRows, int iCols),
             long [ANY][ANY](int *piAddrVar, int iRows, int iCols),
             unsigned long [ANY][ANY](int *piAddrVar, int iRows, int iCols){
  int* _piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_ints || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfInteger32(piAddrVar, &iRows, &iCols,  &_piData);
  if($1!=NULL) {
    free($1);
  }
  $1=($1_ltype)malloc(iRows*sizeof($*1_ltype));
  size_t ii;
  for(ii=0;ii<iRows;ii++){
    $1[ii]=($*1_ltype)malloc(iCols*sizeof($1_basetype));
    size_t jj;
    for(jj=0;jj<iCols;jj++)
    $1[ii][jj]=($1_basetype)_piData[jj*iRows+ii];
  }
}


%typemap(in) double [ANY][ANY](int *piAddrVar, int iRows, int iCols),
             float [ANY][ANY](int *piAddrVar, int iRows, int iCols) {
  double* _piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_matrix || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(piAddrVar, &iRows, &iCols,  &_piData);
  if($1!=NULL) {
    free($1);
  }
  $1=($1_ltype)malloc(iRows*sizeof($*1_ltype));
  size_t ii;
  for(ii=0;ii<iRows;ii++){
    $1[ii]=($*1_ltype)malloc(iCols*sizeof($1_basetype));
    size_t jj;
    for(jj=0;jj<iCols;jj++)
    $1[ii][jj]=($1_basetype)_piData[jj*iRows+ii];
  }
}

%typemap(in) SWIGTYPE *(int *piAddrVar, int iRows, int iCols) {
  $&1_ltype  _piData=($&1_ltype)0;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_matrix || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(piAddrVar, &iRows, &iCols,  &_piData);
  $1=($1_ltype)*_piData;
}
%typemap(in) SWIGTYPE {
  
}

/* -----------------------------------------------------------------------------
 * --- Output arguments --- 
 * ----------------------------------------------------------------------------- */

/* Basic C types */
%typemap(out) signed char (int iRowsOut,int iColsOut,int* _piAddress) {
  char temp;
  temp=(char)($result);
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfInteger8(iVarOut, iRowsOut, iColsOut, &temp, &_piAddress);
  LhsVar(iOutNum)=iVarOut;
}

%typemap(out) short (int iRowsOut,int iColsOut,int* _piAddress),
              unsigned char (int iRowsOut,int iColsOut,int* _piAddress) {
  short temp;
  temp=(short)($result);
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfInteger16(iVarOut, iRowsOut, iColsOut, &temp, &_piAddress);
  LhsVar(iOutNum)=iVarOut;
}

%typemap(out) int (int iRowsOut,int iColsOut,int* _piAddress),
              unsigned int (int iRowsOut,int iColsOut,int* _piAddress),
              unsigned short (int iRowsOut,int iColsOut,int* _piAddress),
              unsigned long (int iRowsOut,int iColsOut,int* _piAddress),
              long (int iRowsOut,int iColsOut,int* _piAddress) {
  int temp;
  temp=(int)($result);
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfInteger32(iVarOut, iRowsOut, iColsOut, &temp, &_piAddress);
  LhsVar(iOutNum)=iVarOut;
}

%typemap(out) double (int iRowsOut,int iColsOut),
              float (int iRowsOut,int iColsOut) {
  double temp;
  temp=(double)($result);
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfDouble(iVarOut, iRowsOut, iColsOut, &temp);
  LhsVar(iOutNum)=iVarOut;
}

%typemap(out) char (int iRowsOut,int iColsOut) {
  char* temp;
  temp=(char*)&($result);
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfString(iVarOut, iRowsOut, iColsOut, &temp);
  LhsVar(iOutNum)=iVarOut;
}

%typemap(out,noblock=1) void {
}

/* Pointers */
%typemap(out) signed char *(int iRowsOut,int iColsOut,int* _piAddress) {
  char *temp;
  temp=(char *)($result);
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfInteger8(iVarOut, iRowsOut, iColsOut, temp, &_piAddress);
  LhsVar(iOutNum)=iVarOut;
}

%typemap(out) short *(int iRowsOut,int iColsOut,int* _piAddress),
              unsigned char *(int iRowsOut,int iColsOut,int* _piAddress) {
  short *temp;
  temp=(short *)($result);
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfInteger16(iVarOut, iRowsOut, iColsOut, temp, &_piAddress);
  LhsVar(iOutNum)=iVarOut;
}

%typemap(out) int *(int iRowsOut,int iColsOut,int* _piAddress),
              unsigned int *(int iRowsOut,int iColsOut,int* _piAddress),
              unsigned short *(int iRowsOut,int iColsOut,int* _piAddress),
              unsigned long *(int iRowsOut,int iColsOut,int* _piAddress),
              long *(int iRowsOut,int iColsOut,int* _piAddress) {
  int *temp;
  temp=(int *)($result);
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfInteger32(iVarOut, iRowsOut, iColsOut, temp, &_piAddress);
  LhsVar(iOutNum)=iVarOut;
}

%typemap(out) double *,
              float * {
  double *temp;
  temp=(double *)($result);
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfDouble(iVarOut, iRowsOut, iColsOut, temp);
  LhsVar(iOutNum)=iVarOut;
  iOutNum++;
  iVarOut++;
}

%typemap(out) char *(int iRowsOut,int iColsOut){
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfString(iVarOut, iRowsOut, iColsOut, &($result));
  LhsVar(iOutNum)=iVarOut;
}

%typemap(freearg, noblock=1) char * { 
  if ($1) free($1);  
}

%typemap(out) SWIGTYPE *(int iRowsOut,int iColsOut) {
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfDouble(iVarOut, iRowsOut, iColsOut, &$result);
  LhsVar(iOutNum)=iVarOut;
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
	                  double {
  double* _piData;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_matrix || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfDouble(piAddrVar, &iRows, &iCols,  &_piData);
  $1=($1_ltype)*_piData;
}

%typemap(varin,noblock=1) char {   
  char* _pstStrings;
  int _piLength;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
    
  if (getVarType(piAddrVar) != sci_strings || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfString(piAddrVar, &iRows, &iCols,&_piLength, &_pstStrings);
  $1=($1_ltype)*_pstStrings;
}

%typemap(varin,noblock=1) char *, 
                char [ANY] {
  char* _pstStrings;
  int _piLength;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_strings || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, $argnum);
  }
  getMatrixOfString(piAddrVar, &iRows, &iCols,&_piLength, &_pstStrings);
  $1=strdup(_pstStrings);
}

%typemap(varin,noblock=1) double *,
                          float * {
  double* _piData;
  int index;
  getVarAddressFromPosition($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) == sci_matrix ){
     if(!isVarComplex(piAddrVar)) {
       isComplex=0;
       getMatrixOfDouble(piAddrVar, &iRows, &iCols,  &_piData);
       if($1!=NULL) {
         free($1);
       }
       $1=($1_ltype)malloc(iRows*iCols*sizeof($*1_ltype));
       for(index=0;index<iRows*iCols;index++){
         $1[index]=($*1_ltype)_piData[index];
       }
     }
     else {
       isComplex=1;
       double *_pdblImg;
       getComplexMatrixOfDouble(piAddrVar, &iRows, &iCols,  &_piData, &_pdblImg);
       if($1!=NULL) {
         free($1);
       }
       $1=($1_ltype)malloc(2*iRows*iCols*sizeof($*1_ltype));
       for(index=0;index<iRows*iCols;index++){
         $1[index]=($*1_ltype)_piData[index];
         $1[index+iRows*iCols]=(double)_pdblImg[index];
       }
     }
  }
  else {
    Scierror(999, _("%s: Wrong type for input argument #%d: double matrix expected.\n"), fname, $argnum);
  }
}

/* -----------------------------------------------------------------------------
 * --- Variable output --- 
 * ----------------------------------------------------------------------------- */
/* Basic C types */
%typemap(varout,noblock=1) signed char {
  int* _piAddress;
  createMatrixOfInteger8(iVarOut, iRowsOut, iColsOut, &$result, &_piAddress);
  LhsVar(iOutNum)=iVarOut;
}

%typemap(varout,noblock=1) short {
  int* _piAddress;
  createMatrixOfInteger16(iVarOut, iRowsOut, iColsOut, &$result, &_piAddress);
  LhsVar(iOutNum)=iVarOut;
}

%typemap(varout,noblock=1) unsigned char {
  int* _piAddress;
  short temp;
  temp=$result;
  createMatrixOfInteger16(iVarOut, iRowsOut, iColsOut, &temp, &_piAddress);
  LhsVar(iOutNum)=iVarOut;
}

%typemap(varout,noblock=1) int,
                           unsigned int,
                           unsigned short,
                           unsigned long,
                           long {
  int* _piAddress;
  createMatrixOfInteger32(iVarOut, iRowsOut, iColsOut, &$result, &_piAddress);
  LhsVar(iOutNum)=iVarOut;
}

%typemap(varout,noblock=1) double {
  createMatrixOfDouble(iVarOut, iRowsOut, iColsOut, &$result);
  LhsVar(iOutNum)=iVarOut;
}

%typemap(varout,noblock=1) float {
  double temp;
  temp=(double)$result;
  createMatrixOfDouble(iVarOut, iRowsOut, iColsOut, &temp);
  LhsVar(iOutNum)=iVarOut;
}

%typemap(varout,noblock=1) char {
  char* temp;
  temp=(char*)&($result);
  createMatrixOfString(iVarOut, iRowsOut, iColsOut, &temp);
  LhsVar(iOutNum)=iVarOut;
}

%typemap(varout,noblock=1) char * {
  createMatrixOfString(iVarOut, iRowsOut, iColsOut, &($result));
  LhsVar(iOutNum)=iVarOut;
}

%typemap(varout,noblock=1) double *,
                           float * {
  if(isComplex) {
    createComplexMatrixOfDouble(iVarOut, iRowsOut, iColsOut, $result,&$result[iRowsOut*iColsOut]);
    LhsVar(iOutNum)=iVarOut;
  }
  else {
    createMatrixOfDouble(iVarOut, iRowsOut, iColsOut, $result);
    LhsVar(iOutNum)=iVarOut;
  }
}

/* ------------------------------------------------------------
 *  Enums mapped as integer values
 * ------------------------------------------------------------ */

%apply int { enum SWIGTYPE };
