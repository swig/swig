/*
 * Scilab list related functions
 *
 */

%fragment("SWIG_ScilabList", "header")
{
SWIGINTERN int
SWIG_GetScilabList(SwigSciObject _obj, int **_piListAddr)
{
  SciErr sciErr;

  sciErr = getVarAddressFromPosition(pvApiCtx, _obj, _piListAddr);
  if (sciErr.iErr)
  {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}

SWIGINTERN int
SWIG_GetScilabListSize(SwigSciObject _obj, int *_piListSize)
{
  SciErr sciErr;
  int *piListAddr;

  sciErr = getVarAddressFromPosition(pvApiCtx, _obj, &piListAddr);
  if (sciErr.iErr)
  {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  sciErr = getListItemNumber(pvApiCtx, piListAddr, _piListSize);
  if (sciErr.iErr)
  {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}

SWIGINTERN int
SWIG_GetScilabListAndSize(SwigSciObject _obj, int **_piListAddr, int *_piListSize)
{
  SciErr sciErr;

  sciErr = getVarAddressFromPosition(pvApiCtx, _obj, _piListAddr);
  if (sciErr.iErr)
  {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  sciErr = getListItemNumber(pvApiCtx, *_piListAddr, _piListSize);
  if (sciErr.iErr)
  {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}

SWIGINTERN int
SWIG_CheckScilabList(SwigSciObject _obj)
{
  SciErr sciErr;
  int *piListAddr;
  int iType;

  sciErr = getVarAddressFromPosition(pvApiCtx, _obj, &piListAddr);
  if (sciErr.iErr)
  {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  sciErr = getVarType(pvApiCtx, piListAddr, &iType);
  if (sciErr.iErr)
  {
    printError(&sciErr, 0);
    return SWIG_ERROR;
  }

  if ((iType != sci_list) && (iType != sci_tlist) && (iType != sci_mlist))
  {
    Scierror(999, _("%s: Wrong type for input argument #%d: A list is expected.\n"), fname, _obj);
    return SWIG_ERROR;
  }

  return SWIG_OK;
}

}

