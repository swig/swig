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
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)*_piData;
}

%typemap(in) char (int iRows, int iCols) {   
  int *piAddrVar;
  int typearg;
  char *_pstStrings;
  int _piLength;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols,&_piLength, (char **)&_pstStrings);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)*_pstStrings;
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
  int *piAddrVar;
  void *_piData = NULL;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)_piData;
}

%typemap(in) char * (int iRows, int iCols){
  int *piAddrVar;
  char *_pstStrings;
  int _piLength;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, NULL);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  _pstStrings = (char *)malloc(sizeof(char) * _piLength + 1);
  
  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, (char **)&_pstStrings);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)strdup(_pstStrings);
  free(_pstStrings);
}

%typemap(in) signed char [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  char *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, (char **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) unsigned char [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  unsigned char *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfUnsignedInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned char **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) short [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  short *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfInteger16(pvApiCtx, piAddrVar, &iRows, &iCols, (short **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) unsigned short [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  unsigned short *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
 
  sciErr = getMatrixOfUnsignedInteger16(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned short **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) int [ANY] (int iRows, int iCols),
	     long [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  int *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
 
  sciErr = getMatrixOfInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (int **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) unsigned int [ANY] (int iRows, int iCols),
	     unsigned long [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  unsigned int *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
 
  sciErr = getMatrixOfUnsignedInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned int **)&_piData);
  
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) double [ANY] (int iRows, int iCols),
             float [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  double *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
 
  sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  for(; ii < (size_t)iCols; ii++){
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) long long [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  long long *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }

  sciErr = getMatrixOfInteger64(pvApiCtx, piAddrVar, &iRows, &iCols, (long long **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  for(; ii < (size_t)iCols; ii++){
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) unsigned long long [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  unsigned long long *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfUnsignedInteger64(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned long long **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  for(; ii < (size_t)iCols; ii++){
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) char [ANY] (int iRows, int iCols) {
  int *piAddrVar;
  char *_pstStrings;
  int _piLength;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
 
  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols,&_piLength, (char **)&_pstStrings);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)strdup(_pstStrings);
}

%typemap(in) signed char [] (int iRows, int iCols) {
  int *piAddrVar;
  char *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }

  sciErr = getMatrixOfInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, (char **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)malloc(sizeof($*1_ltype) * iCols);
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) unsigned char [] (int iRows, int iCols) {
  int *piAddrVar;
  unsigned char *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
 
  sciErr = getMatrixOfUnsignedInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned char **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)malloc(sizeof($*1_ltype) * iCols);
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) short [] (int iRows, int iCols) {
  int *piAddrVar;
  short *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfInteger16(pvApiCtx, piAddrVar, &iRows, &iCols, (short **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)malloc(sizeof($*1_ltype) * iCols);
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) unsigned short [] (int iRows, int iCols) {
  int *piAddrVar;
  unsigned short *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfUnsignedInteger16(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned short **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)malloc(sizeof($*1_ltype) * iCols);
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) int [] (int iRows, int iCols),
	     long [] (int iRows, int iCols) {
  int *piAddrVar;
  int *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)malloc(sizeof($*1_ltype) * iCols);
  sciErr = getMatrixOfInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (int **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) unsigned int [] (int iRows, int iCols),
	     unsigned long [] (int iRows, int iCols) {
  int *piAddrVar;
  unsigned int *_piData;
  size_t ii = 0;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }

  sciErr = getMatrixOfUnsignedInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned int **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)malloc(sizeof($*1_ltype) * iCols);
  for(; ii < (size_t)iCols; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) double [] (int iRows, int iCols),
             float [] (int iRows, int iCols) {
  int *piAddrVar;
  double *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)malloc(sizeof($*1_ltype) * iCols);
  for(; ii < (size_t)iCols; ii++){
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) long long [] (int iRows, int iCols) {
  int *piAddrVar;
  long long *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
 
  sciErr = getMatrixOfInteger64(pvApiCtx, piAddrVar, &iRows, &iCols, (long long **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)malloc(sizeof($*1_ltype) * iCols);
  for(; ii < (size_t)iCols; ii++){
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(in) unsigned long long [] (int iRows, int iCols) {
  int *piAddrVar;
  unsigned long long *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfUnsignedInteger64(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned long long **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)malloc(sizeof($*1_ltype) * iCols);
  for(; ii < (size_t)iCols; ii++){
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

/* Arrays */
%typemap(in) signed char [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  char *_piData;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, (char **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  size_t ii = 0;
  for(; ii < (size_t)iRows; ii++){
    size_t jj = 0;
    for(; jj < (size_t)iCols; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * iRows + ii];
  }
}

%typemap(in) unsigned char [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  unsigned char *_piData;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfUnsignedInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned char **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  size_t ii = 0;
  for(; ii < (size_t)iRows; ii++){
    size_t jj = 0;
    for(; jj < (size_t)iCols; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * iRows + ii];
  }
}

%typemap(in) short [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  short *_piData;
  getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfInteger16(pvApiCtx, piAddrVar, &iRows, &iCols, (short **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  size_t ii = 0;
  for(; ii < (size_t)iRows; ii++){
    size_t jj = 0;
    for(; jj < (size_t)iCols; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * iRows + ii];
  }
}

%typemap(in) unsigned short [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  unsigned short *_piData;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfUnsignedInteger16(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned short **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     } 
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
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (int **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
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
  unsigned int *_piData;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfUnsignedInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned int **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
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
  double *_piData;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  size_t ii = 0;
  for(; ii < (size_t)iRows; ii++){
    size_t jj = 0;
    for(; jj < (size_t)iCols; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * iRows + ii];
  }
}

%typemap(in) long long [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  long long *_piData;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfInteger64(pvApiCtx, piAddrVar, &iRows, &iCols, (long long **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  size_t ii = 0;
  for(; ii < (size_t)iRows; ii++){
    size_t jj = 0;
    for(; jj < (size_t)iCols; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * iRows + ii];
  }
}

%typemap(in) unsigned long long [ANY][ANY] (int iRows, int iCols) {
  int *piAddrVar;
  unsigned long long *_piData;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfUnsignedInteger64(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned long long **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  size_t ii = 0;
  for(; ii < (size_t)iRows; ii++){
    size_t jj = 0;
    for(; jj < (size_t)iCols; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * iRows + ii];
  }
}

%typemap(in) enum SWIGTYPE (int iRows, int iCols) {
  int *piAddrVar;
  int *_piData;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (int **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)*_piData;
}

%typemap(in) SWIGTYPE *,
             SWIGTYPE [] {
  int *piAddrVar;
  void *_piData = NULL;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)_piData;
}

%typemap(in) SWIGTYPE {
  int *piAddrVar;
  void *_piData = NULL;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = *(($&1_ltype)_piData);
}

/* -----------------------------------------------------------------------------
 * --- Output arguments --- 
 * ----------------------------------------------------------------------------- */

/* Basic C types */
%typemap(out) signed char (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  sciErr = createMatrixOfInteger8(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char *)&$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(out) unsigned char (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  sciErr = createMatrixOfUnsignedInteger8(pvApiCtx, iVarOut, iRowsOut, iColsOut, (unsigned char *)&$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(out) short (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  sciErr = createMatrixOfInteger16(pvApiCtx, iVarOut, iRowsOut, iColsOut, (short *)&$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(out) unsigned short (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  sciErr = createMatrixOfUnsignedInteger16(pvApiCtx, iVarOut, iRowsOut, iColsOut, (unsigned short *)&$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(out) int (int iRowsOut, int iColsOut),
              long (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  sciErr = createMatrixOfInteger32(pvApiCtx, iVarOut, iRowsOut, iColsOut, (int *)&$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(out) unsigned int (int iRowsOut, int iColsOut),
              unsigned long (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  sciErr = createMatrixOfUnsignedInteger32(pvApiCtx, iVarOut, iRowsOut, iColsOut, (unsigned int *)&$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(out) double (int iRowsOut, int iColsOut),
              float (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  sciErr = createMatrixOfDouble(pvApiCtx, iVarOut, iRowsOut, iColsOut, (double *)&$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(out) long long (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  sciErr = createMatrixOfInteger64(pvApiCtx, iVarOut, iRowsOut, iColsOut, (long long *)&$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(out) unsigned long long (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  sciErr = createMatrixOfUnsignedInteger64(pvApiCtx, iVarOut, iRowsOut, iColsOut, (unsigned long long *)&$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(out) char (int iRowsOut, int iColsOut) {
  char *temp;
  temp = (char*)&($result);
  iRowsOut = 1; 
  iColsOut = 1;
  sciErr = createMatrixOfString(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char **)&temp);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(out,noblock=1) void {
}


/* Pointers */
%typemap(out) signed char * (int iRowsOut, int iColsOut),
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
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(out) char * (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  sciErr = createMatrixOfString(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char **)&($result));
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(out) enum SWIGTYPE (int iRowsOut, int iColsOut) {
  iRowsOut = 1; 
  iColsOut = 1;
  sciErr = createMatrixOfInteger32(pvApiCtx, iVarOut, iRowsOut, iColsOut, (int *)&$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(out) SWIGTYPE * {
  sciErr = createPointer(pvApiCtx, iVarOut, (void *)$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(out) SWIGTYPE {
  sciErr = createPointer(pvApiCtx, iVarOut, (void *)&$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
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
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)*_piData;
}

%typemap(varin,noblock=1) char {   
  char *_pstStrings;
  int _piLength;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols,&_piLength, (char **)&_pstStrings);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)*_pstStrings;
}

%typemap(varin,noblock=1) char * {
  char *_pstStrings;
  int _piLength;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, NULL);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  _pstStrings = (char *)malloc(sizeof(char) * _piLength + 1);
  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, (char **)&_pstStrings);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)strdup(_pstStrings);
  free(_pstStrings);
}

%typemap(varin,noblock=1) char [ANY] {
  char *_pstStrings;
  int _piLength;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, NULL);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  _pstStrings = (char *)malloc(sizeof(char) * _piLength);
  
  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, &_piLength, (char **)&_pstStrings);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  strcpy($1, _pstStrings);
  free(_pstStrings);
}

%typemap(varin,noblock=1) signed char [ANY] {
  char *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
 
  sciErr = getMatrixOfInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, (char **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) unsigned char [ANY] {
  unsigned char *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  sciErr = getMatrixOfUnsignedInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned char **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) short [ANY] {
  short *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }

  sciErr = getMatrixOfInteger16(pvApiCtx, piAddrVar, &iRows, &iCols, (short **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) unsigned short [ANY] {
  unsigned short *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfUnsignedInteger16(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned short **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) int [ANY],
	                  long [ANY] {
  int *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (int **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) unsigned int [ANY],
	                  unsigned long [ANY] {
  unsigned int *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfUnsignedInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned int **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) double [ANY],
                          float [ANY] {
  double *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  for(; ii < (size_t)$1_dim0; ii++){
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) long long [ANY] {
  int *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }

  sciErr = getMatrixOfInteger64(pvApiCtx, piAddrVar, &iRows, &iCols, (long long **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  for(; ii < (size_t)$1_dim0; ii++) {
    $1[ii] = ($*1_ltype)_piData[ii];
  }
}

%typemap(varin,noblock=1) unsigned long long [ANY] {
  int *_piData;
  size_t ii = 0;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfUnsignedInteger64(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned long long **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
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
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }

  sciErr = getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)_piData;
}

%typemap(varin,noblock=1) char ** {
  char **_pstStrings;
  int *_piLength;
  int i;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  _piLength = (int*)malloc(sizeof(int) * iRows * iCols);
  sciErr = getMatrixOfString(pvApiCtxpiAddrVar, &iRows, &iCols, _piLength, NULL);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }

  _pstStrings = (char**)malloc(iRows * iCols * sizeof(char*));
  for(i = 0; i < iRows * iCols; i++) {
    _pstStrings[i] = (char*)malloc((_piLength[i] + 1) * sizeof(char));
  }
  sciErr = getMatrixOfString(pvApiCtx, piAddrVar, &iRows, &iCols, _piLength, (char **)_pstStrings);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = _pstStrings;
}

/* Arrays */
%typemap(varin,noblock=1) signed char [ANY][ANY] {
  char *_piData;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
 sciErr = getMatrixOfInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, (char **)&_piData);
 if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(varin,noblock=1) unsigned char [ANY][ANY] {
  unsigned char *_piData;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfUnsignedInteger8(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned char **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(varin,noblock=1) short [ANY][ANY] {
  short *_piData;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  sciErr = getMatrixOfInteger16(pvApiCtx, piAddrVar, &iRows, &iCols, (short **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(varin,noblock=1) unsigned short [ANY][ANY] {
  unsigned short *_piData;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfUnsignedInteger16(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned short **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
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
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (int **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
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
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfUnsignedInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned int **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
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
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfDouble(pvApiCtx, piAddrVar, &iRows, &iCols, (double **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(varin,noblock=1) long long [ANY][ANY] {
  long long *_piData;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfInteger64(pvApiCtx, piAddrVar, &iRows, &iCols, (long long **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(varin,noblock=1) unsigned long long [ANY][ANY] {
  unsigned long long *_piData;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getMatrixOfUnsignedInteger64(pvApiCtx, piAddrVar, &iRows, &iCols, (unsigned long long **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  size_t ii = 0;
  for(; ii < (size_t)$1_dim0; ii++){
    size_t jj = 0;
    for(; jj < (size_t)$1_dim1; jj++)
      $1[ii][jj] = ($1_basetype)_piData[jj * $1_dim0+ii];
  }
}

%typemap(varin,noblock=1) enum SWIGTYPE {
  int *_piData;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }

  sciErr = getMatrixOfInteger32(pvApiCtx, piAddrVar, &iRows, &iCols, (int **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)*_piData;
}
%typemap(varin,noblock=1) SWIGTYPE * {
  void *_piData = NULL;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  sciErr = getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = ($1_ltype)_piData;
}

%typemap(varin,noblock=1) SWIGTYPE [ANY] {
  void *_piData = NULL;
  size_t ii;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }  

  sciErr = getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  for(ii = 0; ii < $1_dim0; ii++){
    $1[ii] = (($1_ltype)_piData)[ii];
  }
}

%typemap(varin,noblock=1) SWIGTYPE [ANY][ANY] {
  void *_piData = NULL;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
 
  sciErr = getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
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
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  sciErr = getPointer(pvApiCtx, piAddrVar, (void **)&_piData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  $1 = *(($&1_ltype)_piData);
}

/* -----------------------------------------------------------------------------
 * --- Variable output --- 
 * ----------------------------------------------------------------------------- */
/* Basic C types */
%typemap(varout,noblock=1) signed char {
  char temp = $result;
  sciErr = createMatrixOfInteger8(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char *)&temp);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) unsigned char {
  unsigned char temp = $result;
  sciErr = createMatrixOfUnsignedInteger8(pvApiCtx, iVarOut, iRowsOut, iColsOut, (unsigned char *)&temp);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  

}

%typemap(varout,noblock=1) short {
  short temp = $result;
  sciErr = createMatrixOfInteger16(pvApiCtx, iVarOut, iRowsOut, iColsOut, (short *)&temp);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) unsigned short {
  unsigned short temp = $result;
  sciErr = createMatrixOfUnsignedInteger16(pvApiCtx, iVarOut, iRowsOut, iColsOut, (unsigned short *)&temp);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) int,
                           long {
  int temp = $result;
  sciErr = createMatrixOfInteger32(pvApiCtx, iVarOut, iRowsOut, iColsOut, (int *)&temp);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) unsigned int,
                           unsigned long {
  unsigned int temp = $result;
  sciErr = createMatrixOfUnsignedInteger32(pvApiCtx, iVarOut, iRowsOut, iColsOut, (unsigned int *)&temp);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) double,
                           float {
  double temp = $result;
  sciErr = createMatrixOfDouble(pvApiCtx, iVarOut, iRowsOut, iColsOut, (double *)&temp);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) long long {
  long long temp = $result;
  sciErr = createMatrixOfInteger64(pvApiCtx, iVarOut, iRowsOut, iColsOut, (long long *)&temp);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) unsigned long long {
  unsigned long long temp = $result;
  sciErr = createMatrixOfUnsignedInteger64(pvApiCtx, iVarOut, iRowsOut, iColsOut, (unsigned long long *)&temp);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) char {
  char *temp = (char *)malloc(sizeof($result) + 1);
  *temp = $result;
  *(temp+1) = '\0';
  sciErr = createMatrixOfString(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char **)&temp);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
  free(temp);
}

%typemap(varout,noblock=1) char * {
  char *temp = $result;
  sciErr = createMatrixOfString(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char **)&temp);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
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
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

/* Arrays */
%typemap(varout,noblock=1) char [ANY] {
  char **pstData = NULL;
  pstData = (char **)malloc(sizeof(char *));
  pstData[0] = $result;
  sciErr = createMatrixOfString(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char **)pstData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
   
}

%typemap(varout,noblock=1) signed char [ANY] {
  sciErr = createMatrixOfInteger8(pvApiCtx, iVarOut, 1, $1_dim0, (char *)$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) unsigned char [ANY] {
  sciErr = createMatrixOfUnsignedInteger8(pvApiCtx, iVarOut, 1, $1_dim0, (unsigned char *)$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) short [ANY] {
  sciErr = createMatrixOfInteger16(pvApiCtx, iVarOut, 1, $1_dim0, (short *)$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) unsigned short [ANY] {
  sciErr = createMatrixOfUnsignedInteger16(pvApiCtx, iVarOut, 1, $1_dim0, (unsigned short *)$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) int [ANY],
                           long [ANY] {
  sciErr = createMatrixOfInteger32(pvApiCtx, iVarOut, 1, $1_dim0, (int *)$result); // Celu ci
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) unsigned int [ANY],
                           unsigned long [ANY] {
  sciErr = createMatrixOfUnsignedInteger32(pvApiCtx, iVarOut, 1, $1_dim0, (unsigned int *)$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) double [ANY] {
  sciErr = createMatrixOfDouble(pvApiCtx, iVarOut, 1, $1_dim0, (double *)$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) float [ANY] {
  sciErr = createMatrixOfDouble(pvApiCtx, iVarOut, 1, $1_dim0, (double *)$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) long long [ANY] {
  sciErr = createMatrixOfInteger64(pvApiCtx, iVarOut, 1, $1_dim0, (long long *)$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) unsigned long long [ANY] {
  sciErr = createMatrixOfUnsignedInteger64(pvApiCtx, iVarOut, 1, $1_dim0, (unsigned long long *)$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) char ** {
  char **pstData = NULL;
  pstData = (char **)malloc(iRowsOut * iColsOut * sizeof(char*));
  pstData = $result;
  sciErr = createMatrixOfString(pvApiCtx, iVarOut, iRowsOut, iColsOut, (char **)pstData);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}


%typemap(varout,noblock=1) signed char [ANY][ANY],
                           char [ANY][ANY]{
  sciErr = createMatrixOfInteger8(pvApiCtx, iVarOut, $1_dim0, $1_dim1, (char *)$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) unsigned char [ANY][ANY] {
  sciErr = createMatrixOfUnsignedInteger8(pvApiCtx, iVarOut, $1_dim0, $1_dim1, (unsigned char *)$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) short [ANY][ANY] {
  sciErr = createMatrixOfInteger16(pvApiCtx, iVarOut, $1_dim0, $1_dim1, (short *)$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) unsigned short [ANY][ANY] {
  sciErr = createMatrixOfUnsignedInteger16(pvApiCtx, iVarOut, $1_dim0, $1_dim1, (unsigned short *)$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) int [ANY][ANY],
                           long [ANY][ANY] {
  sciErr = createMatrixOfInteger32(pvApiCtx, iVarOut, $1_dim0, $1_dim1, (int *)$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) unsigned int [ANY][ANY],
                           unsigned long [ANY][ANY] {
  sciErr = createMatrixOfUnsignedInteger32(pvApiCtx, iVarOut, $1_dim0, $1_dim1, (unsigned int *)$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) double [ANY][ANY] {
  sciErr = createMatrixOfDouble(pvApiCtx, iVarOut, $1_dim0, $1_dim1, (double *)$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) float [ANY][ANY] {
  sciErr = createMatrixOfDouble(pvApiCtx, iVarOut, $1_dim0, $1_dim1, (double *)$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) long long [ANY][ANY] {
  sciErr = createMatrixOfInteger64(pvApiCtx, iVarOut, $1_dim0, $1_dim1, (long long *)$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) unsigned long long [ANY][ANY] {
  sciErr = createMatrixOfUnsignedInteger64(pvApiCtx, iVarOut, $1_dim0, $1_dim1, (unsigned long long *)$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}


/* Enums */
%typemap(varout,noblock=1) enum SWIGTYPE {
  sciErr = createMatrixOfInteger32(pvApiCtx, iVarOut, iRowsOut, iColsOut, (int *)&temp);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

/* Other types */
%typemap(varout,noblock=1) SWIGTYPE * {
  sciErr = createPointer(pvApiCtx, iVarOut, (void *)$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

%typemap(varout,noblock=1) SWIGTYPE {
  sciErr = createPointer(pvApiCtx, iVarOut, (void *)&$result);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  
}

/* ------------------------------------------------------------
 * --- Typecheck typemaps ---
 * ------------------------------------------------------------ */
/* Basic C types */
%typecheck(SWIG_TYPECHECK_CHAR) char {
  int *piAddrVar;
  int typearg;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_strings) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INT8) signed char {
  int *piAddrVar;
  int typearg;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_UINT8) unsigned char {
  int *piAddrVar;
  int typearg;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INT16) short {
  int *piAddrVar;
  int typearg;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_UINT16) unsigned short {
  int *piAddrVar;
  int typearg;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INT32) int, 
                                 long {
  int *piAddrVar;
  int typearg;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_UINT32) unsigned int,
                                  unsigned long {
  int *piAddrVar;
  int typearg;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}


%typecheck(SWIG_TYPECHECK_DOUBLE) double {
  int *piAddrVar;
  int typearg;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_FLOAT) float {
  int *piAddrVar;
  int typearg;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_STRING) char * {
  int *piAddrVar;
  int typearg;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_strings) ? 1 : 0;
}

/* Arrays */
%typecheck(SWIG_TYPECHECK_CHAR_ARRAY) char [ANY] {
  int *piAddrVar;
  int typearg;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_strings) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INT8_ARRAY) signed char [ANY] {
  int *piAddrVar;
  int typearg;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INT16_ARRAY) unsigned char [ANY],
                                       short [ANY] {
  int *piAddrVar;
  int typearg;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INT32_ARRAY) unsigned short [ANY],
                                       int [ANY],
                                       long [ANY] {
  int *piAddrVar;
  int typearg;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_INT64_ARRAY) unsigned int [ANY],
                                        unsigned long [ANY] {
  int *piAddrVar;
  int typearg;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_DOUBLE_ARRAY) double [ANY]{
  int *piAddrVar;
  int typearg;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_FLOAT_ARRAY) float [ANY]{
  int *piAddrVar;
  int typearg;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_matrix) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_STRING_ARRAY) char ** {
  int *piAddrVar;
  int typearg;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_strings) ? 1 : 0;
}

%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE * {
  int *piAddrVar;
  int typearg;
  sciErr = getVarAddressFromPosition(pvApiCtx, $argnum, &piAddrVar);
  if (sciErr.iErr) {
	 printError(&sciErr, 0);
	 return 0;
     }
  getVarType(pvApiCtx, piAddrVar, &typearg);
  $1 = (typearg == sci_pointer) ? 1 : 0;
}

/* ------------------------------------------------------------
 *  size_t mapped as int
 * ------------------------------------------------------------ */

%apply int { size_t };
