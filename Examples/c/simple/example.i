/* File : example.i */
%module example

%feature("prepend") {
  printf("Testing...\n");
}

extern int gcd(int x, int y);

