%module inout_typemaps

%include "typemaps.i"
%include "std_pair.i"

%{
  inline void AddOne3(double* a, double* b, double* c) {
    *a += 1;
    *b += 1;
    *c += 1;
  }

  inline void AddOne1(double* a) {
    *a += 1;
  } 

  inline void AddOne1p(std::pair<double, double>* p) {
    p->first += 1;
    p->second += 1;
  } 

  inline void AddOne2p(std::pair<double, double>* p,double* a) {
    *a += 1;
    p->first += 1;
    p->second += 1;
  } 

  inline void AddOne3p(double* a, std::pair<double, double>* p,double* b) {
    *a += 1;
    *b += 1;
    p->first += 1;
    p->second += 1;
  } 

  inline void AddOne1r(double& a) {
    a += 1;
  } 

%}

%template() std::pair<double, double>;

void AddOne1(double* INOUT);
void AddOne3(double* INOUT, double* INOUT, double* INOUT);
void AddOne1p(std::pair<double, double>* INOUT);
void AddOne2p(std::pair<double, double>* INOUT, double* INOUT);
void AddOne3p(double* INOUT, std::pair<double, double>* INOUT, double* INOUT);
void AddOne1r(double& INOUT);

%inline %{
  inline void StringNot(char** INOUT) {
    if ((*INOUT)[0]) { *INOUT = NULL; } else { *INOUT = (char*)"empty"; }
  }

  inline void CharNot(char* INOUT) {
    if (*INOUT) { *INOUT = '\0'; } else { *INOUT = '\xff'; }
  }

  inline void* NonVoidOut(int* INOUT) {
    *INOUT += 42;
    return NULL;
  }
  void *getNull() { return NULL; }
%}

%typemap(out, numoutputs=0) MyErr ""
%typemap(ret) MyErr %{
  // Do something with the error (we don't care really).
%}

%{
  typedef int MyErr;

  inline MyErr SuppressedTwo(int code, int *out1, int *out2) { *out1 = 11; *out2 = 12; return code; }
  inline MyErr SuppressedOne(int code, int *out1) { *out1 = 11; return code; }
  inline MyErr SuppressedNone(int code) { return code; }
%}

MyErr SuppressedTwo(int code, int *OUTPUT, int *OUTPUT);
MyErr SuppressedOne(int code, int *OUTPUT);
MyErr SuppressedNone(int code);

#ifdef VOID_Object
%typemap(out) VoidMaker { $result = VOID_Object; }

%{
  typedef int VoidMaker;
  inline VoidMaker VoidNone() { return 1; }
  inline VoidMaker VoidOne(int *out1) { *out1 = 11; return 1; }
  inline VoidMaker VoidTwo(int *out1, int *out2) { *out1 = 11; *out2 = 12; return 1; }
%}

VoidMaker VoidNone();
VoidMaker VoidOne(int *OUTPUT);
VoidMaker VoidTwo(int *OUTPUT, int *OUTPUT);

#endif
