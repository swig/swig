%module wallkw

// test the -Wallkw option

%warnfilter(SWIGWARN_PARSE_KEYWORD) clone; // 'clone' is a PHP keyword, renaming to 'c_clone'
%warnfilter(SWIGWARN_PARSE_KEYWORD) delegate; // 'delegate' is a C# keyword, renaming to '_delegate'
%warnfilter(SWIGWARN_PARSE_KEYWORD) pass; // 'pass' is a python keyword, renaming to '_pass'
%warnfilter(SWIGWARN_PARSE_KEYWORD) alias; // 'alias' is a D keyword, renaming to '_alias'
%warnfilter(SWIGWARN_PARSE_KEYWORD) rescue; // 'rescue' is a ruby keyword, renaming to 'C_rescue'
%warnfilter(SWIGWARN_PARSE_KEYWORD) write; // 'write' is a fortran keyword, just warn
%warnfilter(SWIGWARN_LANG_IDENTIFIER) _123_leading_underscore; // leading underscores and numbers are illegal in fortran

// Silence warning for renamed identifiers
%warnfilter(SWIGWARN_LANG_IDENTIFIER,SWIGWARN_PARSE_KEYWORD) delegate;
%warnfilter(SWIGWARN_LANG_IDENTIFIER,SWIGWARN_PARSE_KEYWORD) pass;
%warnfilter(SWIGWARN_LANG_IDENTIFIER,SWIGWARN_PARSE_KEYWORD) alias;

%inline %{
const char * clone() { return "clone"; }
const char * delegate() { return "delegate"; }
const char * pass() { return "pass"; }
const char * alias() { return "alias"; }
const char * rescue() { return "rescue"; }
const char * write() { return "write"; }
const char * _123_leading_underscore() { return "_123_leading_underscore"; }
%}

