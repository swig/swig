%module xxx

// With -macroerrors, warnings in nested multiline macros are reported at the line in the macro definition

%define VAL(n)
(n)
%enddef

%define DECLARE(name, n)
const int name = VAL(n);
struct name ## _after : public Nothing0 {};
%enddef

DECLARE(p, 1)
class B1 : public Nothing1 {};
class B2 : public Nothing2 {};
