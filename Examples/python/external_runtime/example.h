/* File : example.h */

#include <iostream>
#include "Python.h"

class Mesh
{
public:
	Mesh(const int value = 0)
	: value_(value) {}
	int value() { return value_;}
private:
	int value_;
};

class Function
{
public:
	explicit Function(PyObject * pyCallable = 0);
	int meshValue() { return meshValue_;}	int meshValue_;

private:
	PyObject * pyObj_;
};
