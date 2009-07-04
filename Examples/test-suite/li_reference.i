%module li_reference

%include "reference.i"

%inline %{
  double FrVal;
  double ToVal;
  void PDouble(double *REFERENCE, int t = 0)
    { ToVal = *REFERENCE; *REFERENCE = FrVal + t; }
  void RDouble(double &REFERENCE, int t = 0)
    { ToVal =  REFERENCE;  REFERENCE = FrVal + t; }
  void PFloat(float *REFERENCE, int t = 0)
    { ToVal = *REFERENCE; *REFERENCE = FrVal + t; }
  void RFloat(float &REFERENCE, int t = 0)
    { ToVal =  REFERENCE;  REFERENCE = FrVal + t; }
  void PInt(int *REFERENCE, int t = 0)
    { ToVal = *REFERENCE; *REFERENCE = FrVal + t; }
  void RInt(int &REFERENCE, int t = 0)
    { ToVal =  REFERENCE;  REFERENCE = FrVal + t; }
  void PShort(short *REFERENCE, int t = 0)
    { ToVal = *REFERENCE; *REFERENCE = FrVal + t; }
  void RShort(short &REFERENCE, int t = 0)
    { ToVal =  REFERENCE;  REFERENCE = FrVal + t; }
  void PLong(long *REFERENCE, int t = 0)
    { ToVal = *REFERENCE; *REFERENCE = FrVal + t; }
  void RLong(long &REFERENCE, int t = 0)
    { ToVal =  REFERENCE;  REFERENCE = FrVal + t; }
  void PUInt(unsigned int *REFERENCE, int t = 0)
    { ToVal = *REFERENCE; *REFERENCE = FrVal + t; }
  void RUInt(unsigned int &REFERENCE, int t = 0)
    { ToVal =  REFERENCE;  REFERENCE = FrVal + t; }
  void PUShort(unsigned short *REFERENCE, int t = 0)
    { ToVal = *REFERENCE; *REFERENCE = FrVal + t; }
  void RUShort(unsigned short &REFERENCE, int t = 0)
    { ToVal =  REFERENCE;  REFERENCE = FrVal + t; }
  void PULong(unsigned long *REFERENCE, int t = 0)
    { ToVal = *REFERENCE; *REFERENCE = FrVal + t; }
  void RULong(unsigned long &REFERENCE, int t = 0)
    { ToVal =  REFERENCE;  REFERENCE = FrVal + t; }
  void PUChar(unsigned char *REFERENCE, int t = 0)
    { ToVal = *REFERENCE; *REFERENCE = FrVal + t; }
  void RUChar(unsigned char &REFERENCE, int t = 0)
    { ToVal =  REFERENCE;  REFERENCE = FrVal + t; }
  void PChar(signed char *REFERENCE, int t = 0)
    { ToVal = *REFERENCE; *REFERENCE = FrVal + t; }
  void RChar(signed char &REFERENCE, int t = 0)
    { ToVal =  REFERENCE;  REFERENCE = FrVal + t; }
  void PBool(bool *REFERENCE, int t = 0)
    { ToVal = *REFERENCE; *REFERENCE = FrVal + t; }
  void RBool(bool &REFERENCE, int t = 0)
    { ToVal =  REFERENCE;  REFERENCE = FrVal + t; }
%}
