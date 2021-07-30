%module cpp17_hex_floating_literals

// Tests are designed so that code compiles with C++98 compilers

%{
#if __cplusplus >= 201703L
#define CPP17 1
#endif
%}

double f1 = 0x.0p1;
double f2 = 0x0.p1;
double f3 = 0x0.0p-1;
double f4 = 0xf.p-1;
double f5 = 0xA.0p1;
double f6 = 0x0.10P+10;
double f7 = 0xb2F.p2;
float f8 = 0x1234AP1F;
float f9 = 0x45A1.D1A2p+10f;

%{
#if defined(CPP17)
double f1 = 0x.0p1;
double f2 = 0x0.p1;
double f3 = 0x0.0p-1;
double f4 = 0xf.p-1;
double f5 = 0xA.0p1;
double f6 = 0x0.10P+10;
double f7 = 0xb2F.p2;
float f8 = 0x1234AP1F;
float f9 = 0x45A1.D1A2p+10f;
#else
double f1 = 0.;
double f2 = 0.;
double f3 = 0.;
double f4 = 7.5;
double f5 = 20.;
double f6 = 64.;
double f7 = 11452.;
float f8 = 149140.f;
float f9 = 18253638.f;
#endif
%}
