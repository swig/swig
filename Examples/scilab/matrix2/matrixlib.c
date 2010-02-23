double sumitems(double *first, int nbRow, int nbCol) {
	int i;
	double total;
	for (i=0; i<(nbRow*nbCol); i++) {
		total+=first[i];
	}
	printf("plop: %6.2f\n",total);
	return total;
}

double* getValues(int *numberOfRow, int *numberOfCol) {
	*numberOfRow=23; *numberOfCol=3;
	double *tempMatrix = (double*)malloc(sizeof(double) * *numberOfRow * *numberOfCol);
	int i;
	for (i=0; i<((*numberOfRow)*(*numberOfCol)); i++) {
		tempMatrix[i]=i*2;
	}
	return tempMatrix;
}
