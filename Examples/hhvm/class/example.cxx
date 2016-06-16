#include<iostream>

using namespace std;

#include "example.h"

#define M_PI 3.14159

int Circle::area() {
  cout<<"Circle::area called"<<endl;
  return M_PI*r*r;
}