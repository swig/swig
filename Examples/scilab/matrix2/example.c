#include <stdlib.h>
#include <stdio.h>
#include <string.h>


// Double matrix functions

double sumDoubleMatrix(double *inputMatrix, int nbRow, int nbCol)
{
	int i;
	double total = 0.0;
	for (i=0; i<nbRow*nbCol; i++)
	{
		total += inputMatrix[i];
	}
	return total;
}

void squareDoubleMatrix(double *inputMatrix, int nbRow, int nbCol, double** resultMatrix, int* nbRowRes, int* nbColRes)
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

void getDoubleMatrix(int nbRow, int nbCol, double **resultMatrix, int *nbRowRes, int *nbColRes)
{
	int i;
	int size;
	*nbRowRes = nbRow;
	*nbColRes = nbCol;
	size = (*nbRowRes) * (*nbColRes);
   	*resultMatrix = (double*) malloc(size * sizeof(double));
	for (i=0; i<size; i++)
	{
		(*resultMatrix)[i] = i*2;
	}
}

void extractDoubleMatrix(double *inputMatrix, int nbRow, int nbCol, int* indexes, int nbIndexes, double **resultMatrix, int *nbRowRes, int *nbColRes)
{
	if (nbIndexes < 0)
	{
		int sz = nbRow * nbCol;
		*nbRowRes = sz;
		*nbColRes = 1;

		*resultMatrix = malloc(sz * sizeof(double));
		memcpy(*resultMatrix, inputMatrix, sz * sizeof(double));
	} else {
		int i;

		*nbRowRes = nbIndexes;
		*nbColRes = 1;

		*resultMatrix = malloc(nbIndexes * sizeof(double));
		for (i = 0; i < nbIndexes; i++)
		{
			(*resultMatrix)[i] = inputMatrix[indexes[i]];
		}
	}
}

// Integer matrix functions

int sumIntegerMatrix(int *inputMatrix, int nbRow, int nbCol)
{
	int i;
	int total = 0;
	for (i=0; i<nbRow*nbCol; i++)
	{
		total += inputMatrix[i];
	}
	return total;
}

void squareIntegerMatrix(int *inputMatrix, int nbRow, int nbCol, int** resultMatrix, int* nbRowRes, int* nbColRes)
{
	int i;
	int size = nbRow * nbCol;
	*nbRowRes = nbRow;
	*nbColRes = nbCol;
	*resultMatrix = (int*) malloc(size * sizeof(int));
	for (i=0; i<size; i++)
	{
		(*resultMatrix)[i] = inputMatrix[i] * inputMatrix[i];
 	}
}

void getIntegerMatrix(int **resultMatrix, int *nbRowRes, int *nbColRes)
{
	int i;
	int size;
	*nbRowRes = 5;
	*nbColRes = 3;
	size = (*nbRowRes) * (*nbColRes);
   	*resultMatrix = (int*) malloc(size * sizeof(int));
	for (i=0; i<size; i++)
	{
		(*resultMatrix)[i] = i*2;
	}
}

// String matrix functions

char* concatStringVector(char **inputVector, int size)
{
	int i;
	int resultSize;
	char *result;
	resultSize = 3 * size + 1;
	result = calloc(resultSize, sizeof(char));
	strcpy(result, inputVector[0]);
	for (i=1; i<size; i++)
	{
		strcat(result, " ");
		strcat(result, (const char*) inputVector[i]);
   	}
   	return result;
}

void getStringVector(char ***resultVector, int *sizeRes)
{
	int i;
	*sizeRes = 12;
   	*resultVector = (char**) malloc((*sizeRes) * sizeof(char*));
	for (i=0; i<*sizeRes; i++)
	{
		char* pc = (char*) calloc(16, sizeof(char));
		sprintf(pc, "%d", i);
		(*resultVector)[i] = pc;
	}
}



