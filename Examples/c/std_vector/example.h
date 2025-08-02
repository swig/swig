/* File : example.h */

#include <string>
#include <vector>

class A {
public:
  A() : name(""), value(0) {}
  A(std::string str, int i) : name(str), value(i) {}
	std::string name;
	int value;
};

class Klass {
public:
	std::vector<int> vi;
	std::vector<A> va;
};
