
// Include fundamental fragemt definitions
%include <typemaps/fragments.swg>

// Look for user fragments file.
%include <scifragments.swg>

// Scilab fragments for primitive types
%include <sciprimtypes.swg>

// Include the unified typemap library
//%include <typemaps/swigtypemaps.swg>


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

%typemap(out) signed char (int iRowsOut,int iColsOut,int* _piAddress) {
  char temp;
  temp=(char)$1;
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfInteger8(Rhs+1, iRowsOut, iColsOut, &temp, &_piAddress);
  LhsVar(1)=Rhs+1;
}

%typemap(out) short (int iRowsOut,int iColsOut,int* _piAddress),
              unsigned char (int iRowsOut,int iColsOut,int* _piAddress) {
  short temp;
  temp=(short)$1;
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfInteger16(Rhs+1, iRowsOut, iColsOut, &temp, &_piAddress);
  LhsVar(1)=Rhs+1;
}

%typemap(out) int (int iRowsOut,int iColsOut,int* _piAddress),
              unsigned int (int iRowsOut,int iColsOut,int* _piAddress),
              unsigned short (int iRowsOut,int iColsOut,int* _piAddress),
              unsigned long (int iRowsOut,int iColsOut,int* _piAddress),
              long (int iRowsOut,int iColsOut,int* _piAddress) {
   int temp;
   temp=(int)$1;
   iRowsOut=1; 
   iColsOut=1;
   createMatrixOfInteger32(Rhs+1, iRowsOut, iColsOut, &temp, &_piAddress);
   LhsVar(1)=Rhs+1;
}


%typemap(out) double (int iRowsOut,int iColsOut,int* _piAddress),
              float (int iRowsOut,int iColsOut,int* _piAddress) {
  double temp;
  temp=(double)$1;
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfDouble(Rhs+1, iRowsOut, iColsOut, &temp, &_piAddress);
  LhsVar(1)=Rhs+1;
}

%typemap(out) char (int iRowsOut,int iColsOut,int* _piAddress) {
  char* temp;
  temp=(char*)&$1;
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfString(Rhs+1, iRowsOut, iColsOut, &temp, &_piAddress);
  LhsVar(1)=Rhs+1;
}


%typemap(out,noblock=1) void {
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

%typemap(out) char *(int iRowsOut,int iColsOut,int* _piAddress){
  iRowsOut=1; 
  iColsOut=1;
  createMatrixOfString(Rhs+1, iRowsOut, iColsOut, &$1, &_piAddress);
  LhsVar(1)=Rhs+1;
}


