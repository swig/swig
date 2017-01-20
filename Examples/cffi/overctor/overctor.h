#ifndef OVERCTOR_H
#define  OVERCTOR_H

#include <stdio.h>

class Vlad {

public:
  Vlad(int intref, char* charstar, double dub);
  Vlad(int intref, char* charstar, char* string2);
  Vlad(int intref, char* charstar);
  Vlad(int intval);
  Vlad();

  int equals(int intval);
  int equals();
  static int equals(int intval, double dub);
  static int equals(double dub);

};

#endif // OVERCTOR_H
