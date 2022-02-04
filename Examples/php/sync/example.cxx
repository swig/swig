#include "example.h"
#include <iostream>

int x = 42;
std::string s = "Test";

void Sync::printer() {
    std::cout << "The value of global s is " << ::s << '\n';
    std::cout << "The value of global x is " << ::x << '\n';
    std::cout << "The value of class s is " << this->s << '\n';
    std::cout << "The value of class x is " << this->x << '\n';
}

void Sync::all_change() {
    ::s = "global change";
    ++::x;
    this->s = "local change";
    ++this->x;
}
