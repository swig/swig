// -*-c++-*-
// Copyright (C) 2000 Tal Shalif

/* File : cpptest.i */
#ifdef SWIGJAVA
%module cpptestJava
#else
%module cpptest
#endif

%include MyString_typemap.i

%{
#define MyString string
#include <string>
#include "cpptest.H"
%}

%include "cpptest.H"

#ifdef SWIGJAVA
%pragma(java) module="
static {
	System.loadLibrary(\"cpptest\");
}";
#endif

// cpptest.i ends here
