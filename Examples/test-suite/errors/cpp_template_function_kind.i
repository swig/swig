%module xxx

template<typename T> int type_parm() { return 1; }
template<int N> int nontype_parm() { return 2; }
template<template<class> class TT> int template_parm() { return 3; }
template<class T> struct Box {};
const int Constant = 4;

%template(type_parm_5) type_parm<5>;
%template(type_parm_constant) type_parm<Constant>;
%template(type_parm_box) type_parm<Box>;
%template(nontype_parm_int) nontype_parm<int>;
%template(nontype_parm_box) nontype_parm<Box>;
%template(template_parm_int) template_parm<int>;
%template(template_parm_5) template_parm<5>;
%template(template_parm_box_int) template_parm<Box<int> >;
