/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * SWIG library file containing macros for manipulating raw C data.
 * ----------------------------------------------------------------------------- */

%typemap(in) (const void *BYTES, size_t LENGTH) (void *buf = 0, int alloc = 0) {
  int len = 0, *piAddrVar = NULL;
  SciErr sciErr = getVarAddressFromPosition(pvApiCtx, $input, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    %argument_fail(SWIG_ERROR,"$type",$symname, $argnum);
  }
  if (!isListType(pvApiCtx, piAddrVar)) {
    %argument_fail(SWIG_ERROR,"$type",$symname, $argnum);
  }
  sciErr = getListItemNumber(pvApiCtx, piAddrVar, &len);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    %argument_fail(SWIG_ERROR,"$type",$symname, $argnum);
  }
  if (len > 0) {
    int i, typ = 0, iRows = 0, iCols = 0, iPrec = 0;
    int* iItemAddress = NULL;
    unsigned char *iVal = NULL;
    double *dVal = NULL;
    unsigned char* cbuf = %new_array(len, unsigned char);
    if (cbuf == NULL) {
      %argument_fail(SWIG_ERROR, "$type", $symname, $argnum);
    }
    buf = cbuf;
    alloc = SWIG_NEWOBJ;
    for (i = 0; i < len; i++) {
      sciErr = getListItemAddress(pvApiCtx, piAddrVar, i + 1, &iItemAddress);
      if (sciErr.iErr) {
        printError(&sciErr, 0);
        %argument_fail(SWIG_ERROR, "$type", $symname, $argnum);
      }
      sciErr = getVarType(pvApiCtx, iItemAddress, &typ);
      if (sciErr.iErr) {
        printError(&sciErr, 0);
        %argument_fail(SWIG_ERROR, "$type", $symname, $argnum);
      }
      switch(typ) {
        case sci_matrix:
          sciErr = getMatrixOfDouble(pvApiCtx, iItemAddress, &iRows, &iCols, &dVal);
          if (sciErr.iErr) {
            printError(&sciErr, 0);
            %argument_fail(SWIG_ERROR,"$type",$symname, $argnum);
          }
          if (iRows * iCols != 1) {
            Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong size for input argument #%d: A 8-bit unsigned integer or a double expected.\n"), fname, $argnum);
            %argument_fail(SWIG_ERROR,"$type",$symname, $argnum);
          }
          if (*dVal != floor(*dVal)) {
            Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Incorrect value for input argument #%d: The double value cannot be converted to a 8-bit unsigned integer.\n"), fname, $argnum);
            %argument_fail(SWIG_ERROR,"$type",$symname, $argnum);
          }
          if (*dVal < 0 || *dVal > UCHAR_MAX) {
            Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Overflow error for input argument #%d: The double value cannot be converted to a 8-bit unsigned integer.\n"), fname, $argnum);
            %argument_fail(SWIG_ERROR,"$type",$symname, $argnum);
          }
          cbuf[i] = (unsigned char)(*dVal);
          break;
        case sci_ints:
          sciErr = getMatrixOfIntegerPrecision(pvApiCtx, iItemAddress, &iPrec);
          if (sciErr.iErr) {
            printError(&sciErr, 0);
            %argument_fail(SWIG_ERROR,"$type",$symname, $argnum);
          }
          if (iPrec != SCI_UINT8) {
            Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong type for input argument #%d: A 8-bit unsigned integer or a double expected.\n"), fname, $argnum);
            %argument_fail(SWIG_ERROR,"$type",$symname, $argnum);
          }
          sciErr = getMatrixOfUnsignedInteger8(pvApiCtx, iItemAddress, &iRows, &iCols, &iVal);
          if (sciErr.iErr) {
            printError(&sciErr, 0);
            return SWIG_ERROR;
          }
          if (iRows * iCols != 1) {
            Scierror(SCILAB_API_ARGUMENT_ERROR, _("%s: Wrong size for input argument #%d: A 8-bit unsigned integer or a double expected.\n"), fname, $argnum);
            return SWIG_ERROR;
          }
          cbuf[i] = *iVal;
          break;
        default:
          %argument_fail(SWIG_ERROR, "$type", $symname, $argnum);
          break;
      }
    }
  }
  $1 = %reinterpret_cast(buf, $1_ltype);
  $2 = %numeric_cast(len, $2_ltype);
}

%typemap(freearg,noblock=1,match="in") (const void *BYTES, size_t LENGTH) {
  if (alloc$argnum == SWIG_NEWOBJ) {
    %delete_array((%reinterpret_cast(buf$argnum, unsigned char *)));
  }
}

%{
SWIGINTERN int SWIG_setUint8List(void *pvApiCtx, const void *buf, size_t len) {
  int iVarOut = SWIG_NbInputArgument(pvApiCtx) + SWIG_Scilab_GetOutputPosition();
  const unsigned char *cbuf = NULL;
  int *piAddrVar = NULL;
  SciErr sciErr;
  if (buf != NULL) {
    cbuf = (unsigned char *)buf;
  } else {
    len = 0;
  }
  sciErr = createList(pvApiCtx, iVarOut, len, &piAddrVar);
  if (sciErr.iErr) {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }
  if (len > 0) {
    size_t i;
    for (i = 0; i < len; i++) {
      sciErr = createMatrixOfUnsignedInteger8InList(pvApiCtx, iVarOut, piAddrVar, (int)(i + 1), 1, 1, cbuf + i);
      if (sciErr.iErr) {
        printError(&sciErr, 0);
        return SWIG_ERROR;
      }
    }
  }
  return SWIG_OK;
}
%}

%typemap(directorin,noblock=1,fragment="SWIG_FromCharPtrAndSize") (const void *BYTES, size_t LENGTH) {
  $input = SWIG_setUint8List(pvApiCtx, $1, (size_t)$2);
}

%apply (const void *BYTES, size_t LENGTH) { (void *BYTES, size_t LENGTH) }

%include <typemaps/cdata_begin.swg>

%typemap(out,noblock=1,fragment="SWIG_FromCharPtrAndSize") SWIGCDATA {
  %set_output(SWIG_setUint8List(pvApiCtx, $1.data, (size_t)($1.len)));
}

%include <typemaps/cdata_end.swg>
