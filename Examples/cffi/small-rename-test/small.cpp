
#include "small.h"
#include <stdio.h>

#if 0
int func (double onlyarg) {   printf("\nin  func : returning 8\n"); return 8; }
int Func (double onlyarg) {   printf("\nin  Func : returning 8\n"); return 8; }
int FUNC (double onlyarg) {   printf("\nin  FUNC : returning 8\n"); return 8; }


int testclass::cppmethod() {    printf("\nin  testclass::cppmethod : returning 8\n"); return 8; }
int TestClass::CppMethod() {    printf("\nin  TestClass::CppMethod : returning 8\n"); return 8; }
int TESTCLASS::CPPMETHOD() {    printf("\nin  TESTCLASS::CPPMETHOD : returning 8\n"); return 8; }

int testclass::cppmethod(int a) {    printf("\nin  testclass::cppmethod(int a) : returning 8\n"); return 8; }
int TestClass::CppMethod(int a) {    printf("\nin  TestClass::CppMethod(int a) : returning 8\n"); return 8; }
int TESTCLASS::CPPMETHOD(int a) {    printf("\nin  TESTCLASS::CPPMETHOD(int a) : returning 8\n"); return 8; }
#endif


int TESTCLASS::oldme()      {    printf("\nin  arity 0  TESTCLASS::oldme : returning 8\n"); return 8; }
int TESTCLASS::oldme(int a) {    printf("\nin  arity 1 int  TESTCLASS::oldme(int a) : returning 9\n"); return 9; }
int TESTCLASS::oldme(double a) {    printf("\nin  arity 1 double  TESTCLASS::oldme(double a) : returning 7\n"); return 7; }
int TESTCLASS::oldme(int a, int b) {    printf("\nin  arity 2 int,int  TESTCLASS::oldme(int, int) : returning 6\n"); return 6; }
int TESTCLASS::oldme(int a, double b) {    printf("\nin  arity 2 int,double  TESTCLASS::oldme(int, double) : returning 5\n"); return 5; }

int TESTCLASS::planet(int a) {    printf("\nin  TESTCLASS::planet(int a) : returning 4\n"); return 4; }
int TESTCLASS::brother()      {    printf("\nin  TESTCLASS::brother() : returning 3\n"); return 3; }
int TESTCLASS::from_another()      {    printf("\nin  TESTCLASS::from_another() : returning 2\n"); return 2; }





