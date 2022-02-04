/* File : example.h */
#pragma once
#include <vector>

class BaseClass {
public:
  BaseClass();
  BaseClass(int i_in);
  virtual ~BaseClass();

  virtual float foo() const = 0;

  int get_i() const { return _i; }

  void set_i(int i) {
    _i = i;
    return;
  }

private:
  int _i;
};

class DerivedA : public BaseClass {
public:
  DerivedA();
  DerivedA(int i, float f);
  virtual ~DerivedA();

  float foo() const;

  void print() const;

private:
  float _f;
  std::vector<int> _data;
};

class DerivedB : public BaseClass {
public:
  DerivedB();
  DerivedB(int i, int i2);
  virtual ~DerivedB();

  float foo() const;

private:
  int _i2;
};

