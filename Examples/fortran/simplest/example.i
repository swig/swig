/* File : example.i */
%module example

%inline {
int add(int a, int b) {
    return a + b;
}
}

