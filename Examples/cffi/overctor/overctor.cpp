#include <stdio.h>
#include "overctor.h"


Vlad::Vlad(int intref, char* charstar, double dub) { printf("in   Vlad(int intref='%d', char* charstar='%s', double dub='%f');\n",intref,charstar,dub); }
Vlad::Vlad(int intref, char* charstar, char* string2) { printf("in   Vlad(int intref, char* charstar, char* string2);\n"); }
Vlad::Vlad(int intref, char* charstar = NULL) { printf("in   Vlad(int intref, char* charstar = NULL);\n"); }
Vlad::Vlad(int intval) { printf("in   Vlad(int intval);\n"); }
Vlad::Vlad() { printf("in   Vlad();\n"); }


int Vlad::equals(int intval) { printf("in  Vlad::equals(int intval);\n"); }
int Vlad::equals() { printf("in  Vlad::equals();\n"); }
int Vlad::equals(int intval, double dub) { printf("in  Vlad::equals(int intval, double dub);\n"); }
int Vlad::equals(double dub) { printf("in  Vlad::equals(double dub);\n"); }




