/* File : simplest.i */
%module simplest

%inline {
int add(int a, int b) {
    return a + b;
}
}
/* vim: set ts=2 sw=2 sts=2 tw=129 : */
