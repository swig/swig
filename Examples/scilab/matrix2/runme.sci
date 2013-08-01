exec loader.sce

// Test lib double matrix functions
disp("Call lib function getDoubleMatrix()");
doubleMatrix = getDoubleMatrix();
disp(doubleMatrix);

disp("Call lib function sumDoubleMatrix()");
s = sumDoubleMatrix(doubleMatrix);
disp(s);

disp("Call lib function squareDoubleMatrix()");
squareDoubleMatrix = squareDoubleMatrix(doubleMatrix);
disp(squareDoubleMatrix);


// Test lib integer matrix functions

disp("Call lib function getIntegerMatrix()");
integerMatrix = getIntegerMatrix();
disp(integerMatrix);

disp("Call lib function sumIntegerMatrix()");
s = sumIntegerMatrix(integerMatrix);
disp(s);

disp("Call lib function squareIntegerMatrix()");
squareIntegerMatrix = squareIntegerMatrix(integerMatrix);
disp(squareIntegerMatrix);


// Test lib string matrix functions

disp("Call lib function getStringVector()");
stringVector = getStringVector();
disp(stringVector);

disp("Call lib function concatStringVector()");
stringVector2 = concatStringVector(stringVector);
disp(stringVector2);

exit



