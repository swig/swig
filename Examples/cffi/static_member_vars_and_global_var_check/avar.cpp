#include <stdio.h>
#include "avar.h"

MicroTestCppClass::MicroTestCppClass() { a_global_int = 44;}

int MicroTestCppClass::show() { printf(" a_global_int=%d\n",a_global_int);  return a_global_int; }

int MicroTestCppClass::take(int a) { a_global_int = a; printf("setting  a_global_int=%d\n",a_global_int);  return a_global_int; }

int a_global_int;


int MicroTestCppClass::StaticPublicMemberInt = 3;
