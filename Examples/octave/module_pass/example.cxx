#include "example.h"

ExClass::ExClass(int val) : val(val) {}

int ExClass::operator() (void) const { return val; }

