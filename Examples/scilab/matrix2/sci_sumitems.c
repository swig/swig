#include "api_scilab.h"

double sumitems(double *first, int nbRow, int nbCol);
double* getValues(int *numberOfRow, int *numberOfCol);

int sci_sumitems(char *fname,unsigned long fname_len)
{

	int iRows			= 0;
	int iCols			= 0;

	int *piAddr			= NULL;
	double* pdblReal	= NULL;

	CheckInputArgument(pvApiCtx, 1, 1);
	CheckOutputArgument(pvApiCtx, 1, 1);

	SciErr sciErr;

	//get variable address of the first input argument
	sciErr = getVarAddressFromPosition(pvApiCtx, 1, &piAddr);
	if(sciErr.iErr)
	{
		printError(&sciErr, 0);
		return 0;
	}


	sciErr = getMatrixOfDouble(pvApiCtx, piAddr, &iRows, &iCols, &pdblReal);

	double plop = sumitems(pdblReal, iRows, iCols);
/* 
 * Here, it is a scalar but it could be also a matrix... don't assume it 
 * it will be always 1x1
 */
	int iRowsReturn=1;
	int iColReturn=1;
	sciErr = createMatrixOfDouble(pvApiCtx, Rhs + 1, iRowsReturn, iColReturn, &plop);

	if(sciErr.iErr)
	{
		printError(&sciErr, 0);
		return 0;
	}

    AssignOutputVariable(1) = nbInputArgument + 1;
	return 0;

}


int sci_getValues(char *fname,unsigned long fname_len)
{

	int iRows			= 0;
	int iCols			= 0;

	int *piAddr			= NULL;
	double* pdblReal	= NULL;

	CheckInputArgument(pvApiCtx, 0, 0);
	CheckOutputArgument(pvApiCtx, 1, 1);

	SciErr sciErr;


	int numberRow, numberCol, i;
	double * matrix = getValues(&numberRow, &numberCol);

	sciErr = createMatrixOfDouble(pvApiCtx, Rhs + 1, numberRow, numberCol, matrix);

	if(sciErr.iErr)
	{
		printError(&sciErr, 0);
		return 0;
	}

	AssignOutputVariable(1) = nbInputArgument + 1;
	return 0;

}
