%module scilab_identifier_name


// Test identifier name truncating
// (when variables, fonctions, constants names exceed 24 charaters long)

%inline %{

// These identifier names wont be truncated
int gvar_identifier_name = -1;
#define CONS_IDENTIFIER_NAME -11
int function_identifier_name() { return -21; };

// These identifier names will be truncated
int too_long_gvar_identifier_name_1 = 1;
int too_long_gvar_identifier_name_2 = 2;

#define TOO_LONG_CONST_IDENTIFIER_NAME_1 11
#define TOO_LONG_CONST_IDENTIFIER_NAME_2 12

int too_long_function_identifier_name_1() { return 21; };
int too_long_function_identifier_name_2() { return 22; };

%}


// Test when %scilabconst mode is activated
%scilabconst(1);

%inline %{
#define SC_CONST_IDENTIFIER_NAME -12;

#define SC_TOO_LONG_CONST_IDENTIFIER_NAME_1 13
#define SC_TOO_LONG_CONST_IDENTIFIER_NAME_2 14
%}
