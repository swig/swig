%module cpp17_hex_floating_literals

%inline %{
double f1 = 0x.0p1;
double f2 = 0x0.p1;
double f3 = 0x0.0p-1;
double f4 = 0xf.p-1;
double f5 = 0xA.0p1;
double f6 = 0x0.10P+10;
double f7 = 0xb2F.p2;
float f8 = 0x1234AP1F;
float f9 = 0x45A1.D1A2p+10f;
%}
