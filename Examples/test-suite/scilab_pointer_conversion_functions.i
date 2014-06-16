%module scilab_pointer_conversion_functions

%inline %{

void* getNull() { return NULL; }
bool isNull(void *p) { return p == NULL; }

int foo = 3;
int *pfoo = &foo;

double getFooAddress() { return (double) (unsigned long) pfoo; }
bool equalFooPointer(void *p) { return p == pfoo; }

%}


