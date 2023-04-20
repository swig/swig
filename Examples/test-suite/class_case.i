%module class_case

// Regression test for SWIG/Go bug #676

%inline %{

class ClassA {};

class classB {};
class classB2 : public classB {};

int Test1(ClassA* a) { return 1; }
int Test1(int i) { return 0; }

int Test2(classB* a) { return 1; }
int Test2(int i) { return 0; }

%}
