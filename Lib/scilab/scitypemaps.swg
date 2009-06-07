
// Include fundamental fragemt definitions
%include <typemaps/fragments.swg>

// Look for user fragments file.
%include <scifragments.swg>

// Scilab fragments for primitive types
%include <sciprimtypes.swg>

// Include the unified typemap library
//%include <typemaps/swigtypemaps.swg>


%typemap(in) char (int *piAddrVar, int iRows, int iCols),
             signed char (int *piAddrVar, int iRows, int iCols),
             unsigned char(int *piAddrVar, int iRows, int iCols)
{
    char* _piData8;
    getVarAddressFromNumber($argnum, &piAddrVar);
    getVarDimension(piAddrVar, &iRows, &iCols);
    if(getVarType(piAddrVar) != sci_matrix || iRows1 != 1 || iCols1 != 1 || isVarComplex(piAddrVar))
	{
		Scierror(999,_("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, 1);
	}
    getMatrixOfInteger8(piAddrVar, &iRows, &iCols,  &_piData8);
     $1=_piData8[0];
}

%typemap(in) short (int *piAddrVar, int iRows, int iCols),
           unsigned  short (int *piAddrVar, int iRows, int iCols)
             
{   short* _piData16;
    getVarAddressFromNumber($argnum, &piAddrVar);
    getVarDimension(piAddrVar, &iRows, &iCols);
    if(getVarType(piAddrVar) != sci_matrix || iRows1 != 1 || iCols1 != 1 || isVarComplex(piAddrVar))
	{
		Scierror(999,_("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, 1);
	}
   getMatrixOfInteger16(piAddrVar, &iRows, &iCols, &_piData16);
   $1= _piData16[0];

}

%typemap(in) int (int *piAddrVar, int iRows, int iCols),
           unsigned int (int *piAddrVar, int iRows, int iCols)
             
{   int* _piData32;
    getVarAddressFromNumber($argnum, &piAddrVar);
    getVarDimension(piAddrVar, &iRows, &iCols);
    if(getVarType(piAddrVar) != sci_matrix || iRows1 != 1 || iCols1 != 1 || isVarComplex(piAddrVar))
	{
		Scierror(999,_("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, 1);
	}
   getMatrixOfInteger16(piAddrVar, &iRows, &iCols, &_piData32);
   $1= _piData32[0];

}

%typemap(in) long(int* piAddrVar,int iRows,int iCols),
             unsigned long(int* piAddrVar,int iRows,int iCols),
             double(int* piAddrVar,int iRows,int iCols),
             float (int* piAddrVar,int iRows,int iCols)
                
{  double *pdblReal;
    getVarAddressFromNumber($argnum, &piAddrVar);
    getVarDimension(piAddrVar, &iRows, &iCols);
    if(getVarType(piAddrVar) != sci_matrix || iRows1 != 1 || iCols1 != 1 || isVarComplex(piAddrVar))
	{
		Scierror(999,_("%s: Wrong type for input argument #%d: Real scalar expected.\n"), fname, 1);
	}
   getMatrixOfDouble(piAddrVar, &iRows, &iCols, &pdblReal);
   $1= pdblReal[0];

}

/*
%typemap(in) char *(int m,int n,int l)
{
  if (GetType($argnum) == sci_strings)
 { 
  GetRhsVar($argnum,STRING_DATATYPE,&m,&n,&l);
  $1=($1_ltype)strdup(cstk(l));
 }
 else
   Scierror(999,"error ...\n");

}*/


%typemap(out) char (int iRowsOut,int iColsOut,int* _piAddress),
             signed char (int iRowsOut,int iColsOut,int* _piAddress),
             unsigned char(int iRowsOut,int iColsOut,int* _piAddress)
{
   iRowsOut=1; 
   iColsOut=1;
   createMatrixOfInteger8(Rhs+1, iRowsOut, iColsOut, &$1, &_piAddress);
   LhsVar(1)=Rhs+1;
   PutLhsVar();
}

%typemap(out) short (int iRowsOut,int iColsOut,int* _piAddress),
             unsigned short(int iRowsOut,int iColsOut,int* _piAddress)
            
{
   iRowsOut=1; 
   iColsOut=1;
   createMatrixOfInteger16(Rhs+1, iRowsOut, iColsOut, &$1, &_piAddress);
   LhsVar(1)=Rhs+1;
   PutLhsVar();
}

%typemap(out) int (int iRowsOut,int iColsOut,int* _piAddress),
             unsigned int(int iRowsOut,int iColsOut,int* _piAddress)
            
{
   iRowsOut=1; 
   iColsOut=1;
   createMatrixOfInteger32(Rhs+1, iRowsOut, iColsOut, &$1, &_piAddress);
   LhsVar(1)=Rhs+1;
   PutLhsVar();
}


%typemap(out) long(int iRowsOut,int iColsOut,int* _piAddress),
             unsigned long(int iRowsOut,int iColsOut,int* _piAddress),
             double(int iRowsOut,int iColsOut,int* _piAddress),
              float(int iRowsOut,int iColsOut,int* _piAddress)
{
   iRowsOut=1; 
   iColsOut=1;
   createMatrixDouble(Rhs+1, iRowsOut, iColsOut, &$1, &_piAddress);
   LhsVar(1)=Rhs+1;
   PutLhsVar();
}


%typemap(out,noblock=1) void
{
}


