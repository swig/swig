#include <stdlib.h>
double sumitems(double *first, int nbRow, int nbCol) {
	int i;
	double total;
	for (i=0; i<(nbRow*nbCol); i++) {
		total+=first[i];
	}
	return total;
}

void sumitems_argoutput(double *first, int nbRow, int nbCol,double** result,int* nbrowres,int* nbcolsres) {
	int i;
	*nbrowres=nbRow;
	*nbcolsres=nbCol;
	*result=malloc(nbRow*nbCol*sizeof(double));
	for (i=0; i<(nbRow*nbCol); i++) {
		(*result)[i]=first[i]+first[i];
 	}
	return;
}

double* getValues(int *numberOfRow, int *numberOfCol) {
	double *tempMatrix ;
	int i;
	*numberOfRow=23; *numberOfCol=3;
   tempMatrix= (double*)malloc(sizeof(double )* *numberOfRow * *numberOfCol);

	for (i=0; i<((*numberOfRow)*(*numberOfCol)); i++) {
		tempMatrix[i]=i*2;
	}
	return tempMatrix;
}
