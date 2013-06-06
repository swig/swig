exec loader.sce

disp("Call lib function getMatrix()");
matrix1 = getMatrix();
disp(matrix1);

disp("Call lib function sumMatrixElements()");
s = sumMatrixElements(matrix1);
disp(s);

disp("Call lib function squareMatrixElements()");
squareMatrix = squareMatrixElements(matrix1);
disp(squareMatrix);

