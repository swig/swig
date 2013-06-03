#include <stdlib.h>

double sumMatrixElements(double *inputMatrix, int nbRow, int nbCol)
{
	int i;
	double total = 0.0;
	for (i=0; i<nbRow*nbCol; i++)
	{
		total += inputMatrix[i];
	}
	return total;
}

void squareMatrixElements(double *inputMatrix, int nbRow, int nbCol, double** resultMatrix, int* nbRowRes, int* nbColRes)
{
	int i;
	int size = nbRow * nbCol;
	*nbRowRes = nbRow;
	*nbColRes = nbCol;
	*resultMatrix = (double*) malloc(size * sizeof(double));
	for (i=0; i<size; i++)
	{
		(*resultMatrix)[i] = inputMatrix[i] * inputMatrix[i];
 	}
}

void getMatrix(double **resultMatrix, int *nbRowRes, int *nbColRes)
{
	int i;
	int size;
	*nbRowRes = 5;
	*nbColRes = 3;
	size = (*nbRowRes) * (*nbColRes);
   	*resultMatrix = (double*) malloc(size * sizeof(double));
	for (i=0; i<size; i++)
	{
		(*resultMatrix)[i] = i*2;
	}
}
