/* File : simplest.i */
%module simplest

%inline {
int add(int a, int b) {
    return a + b;
}
}

