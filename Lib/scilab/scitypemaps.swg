
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
  getVarAddressFromNumber($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_matrix || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, 1);
  }
  getMatrixOfDouble(piAddrVar, &iRows, &iCols,  &_piData);
  $1=($1_ltype)*_piData;
}

%typemap(in) char (int *piAddrVar, int iRows, int iCols) {   
  char* _pstStrings;
  int _piLength;
  getVarAddressFromNumber($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
    
  if (getVarType(piAddrVar) != sci_strings || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, 1);
  }
  getMatrixOfString(piAddrVar, &iRows, &iCols,&_piLength, &_pstStrings);
  $1=($1_ltype)*_pstStrings;
}

/* Pointers */
%typemap(in) signed char *(int *piAddrVar, int iRows, int iCols, signed char temp),
	     unsigned char *(int *piAddrVar, int iRows, int iCols, unsigned char temp),
	     short *(int *piAddrVar, int iRows, int iCols, short temp),
	     unsigned short *(int *piAddrVar, int iRows, int iCols, unsigned short temp),
	     int *(int *piAddrVar, int iRows, int iCols, int temp),
	     unsigned int *(int *piAddrVar, int iRows, int iCols, unsigned int temp),
	     long *(int *piAddrVar, int iRows, int iCols, long temp),
	     unsigned long *(int *piAddrVar, int iRows, int iCols, unsigned long temp),
	     float *(int *piAddrVar, int iRows, int iCols, float temp),
	     double *(int *piAddrVar, int iRows, int iCols, double temp) {
  double* _piData;
  getVarAddressFromNumber($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_matrix || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, 1);
  }
  getMatrixOfDouble(piAddrVar, &iRows, &iCols,  &_piData);
  if($1!=NULL) {
    free($1);
  }
  $1=($1_ltype)malloc(iRows*iCols*sizeof($*1_ltype));
  memcpy($1,_piData,iRows*iCols*sizeof($*1_ltype));
  //temp=($*1_ltype)*_piData;
  //$1=&temp;
}

%typemap(in) char *(int *piAddrVar, int iRows, int iCols) {
  char* _pstStrings;
  int _piLength;
  getVarAddressFromNumber($argnum, &piAddrVar);
  getVarDimension(piAddrVar, &iRows, &iCols);
  
  if (getVarType(piAddrVar) != sci_strings || iRows != 1 || iCols != 1 || isVarComplex(piAddrVar)) {
    Scierror(999, _("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, 1);
  }
  getMatrixOfString(piAddrVar, &iRows, &iCols,&_piLength, &_pstStrings);
  $1=strdup(_pstStrings);
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
  iOutNum++;
  iVarOut++;
}

%typemap(out) short (int iRowsOut,int iColsOut,int* _piAddress),
              unsigned char (int iRowsOut,int iColsOut,int* _piAddress) {
  short temp;
  temp=(short)($result);
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfInteger16(iVarOut, iRowsOut, iColsOut, &temp, &_piAddress);
  LhsVar(iOutNum)=iVarOut;
  iOutNum++;
  iVarOut++;
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
  iOutNum++;
  iVarOut++;
}

%typemap(out) double (int iRowsOut,int iColsOut,int* _piAddress),
              float (int iRowsOut,int iColsOut,int* _piAddress) {
  double temp;
  temp=(double)($result);
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfDouble(iVarOut, iRowsOut, iColsOut, &temp, &_piAddress);
  LhsVar(iOutNum)=iVarOut;
  iOutNum++;
  iVarOut++;
}

%typemap(out) char (int iRowsOut,int iColsOut,int* _piAddress) {
  char* temp;
  temp=(char*)&($result);
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfString(iVarOut, iRowsOut, iColsOut, &temp, &_piAddress);
  LhsVar(iOutNum)=iVarOut;
  iOutNum++;
  iVarOut++;
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
  iOutNum++;
  iVarOut++;
}

%typemap(out) short *(int iRowsOut,int iColsOut,int* _piAddress),
              unsigned char *(int iRowsOut,int iColsOut,int* _piAddress) {
  short *temp;
  temp=(short *)($result);
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfInteger16(iVarOut, iRowsOut, iColsOut, temp, &_piAddress);
  LhsVar(iOutNum)=iVarOut;
  iOutNum++;
  iVarOut++;
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
  iOutNum++;
  iVarOut++;
}

%typemap(out) double *(int iRowsOut,int iColsOut,int* _piAddress),
              float *(int iRowsOut,int iColsOut,int* _piAddress) {
  double *temp;
  temp=(double *)($result);
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfDouble(iVarOut, iRowsOut, iColsOut, temp, &_piAddress);
  LhsVar(iOutNum)=iVarOut;
  iOutNum++;
  iVarOut++;
}

%typemap(out) char *(int iRowsOut,int iColsOut,int* _piAddress){
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfString(iVarOut, iRowsOut, iColsOut, &($result), &_piAddress);
  LhsVar(iOutNum)=iVarOut;
  iOutNum++;
  iVarOut++;
}

/* ------------------------------------------------------------
 *  Enums mapped as integer values
 * ------------------------------------------------------------ */

%apply int { enum SWIGTYPE };
