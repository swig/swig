%module xxx

// With -macroerrors, warnings in multiline macros are reported at the line in the macro definition

%define DECLARE(name)
struct name ## _after : public Nothing0 {};
%enddef

DECLARE(p)
class B1 : public Nothing1 {};
class B2 : public Nothing2 {};
