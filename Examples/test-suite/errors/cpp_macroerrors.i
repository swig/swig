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

// A multiline macro call as an argument passed on to another multiline macro
DECLARE(q, VAL(2))
class B3 : public Nothing3 {};

%define DECLARE_STRUCT(name, n)
const int name = n;
struct name ## _struct : public Nothing4 {};
%enddef

%define DECLARE2(name, n)
DECLARE_STRUCT(name, n)
struct name ## _after2 : public Nothing5 {};
%enddef

DECLARE2(r, VAL(3))
class B6 : public Nothing6 {};
