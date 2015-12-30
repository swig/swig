%module "python_enum_strong_scoped"
%include <enums.swg>

%feature("python:enum",strong=1) Color1;
%feature("python:enum",scoped=1) Color2;
%feature("python:enum",scoped=1, strong=1) Color3;
%feature("python:enum",scoped=1) Color4;

%inline {
enum Color0 { GRAY, LIGHTGRAY };                                  // classic enum (but affected by enums.swg)
enum Color1 { RED, GREEN, BLUE };                                 // strong enum (with predefined values)
enum Color2 { CYAN = 20, MAGENTA = 21, YELLOW = 22, BLACK = 23 }; // scoped enum (with predefined values)
enum Color3 { BROWN = 31 };                                       // strong scoped enum (with default values)
enum Color4 { C4_BROWN = BROWN };                                 // scoped enum (with predefined value set to other enum)

Color0 get_Color0_GRAY() { return GRAY; }
Color0 get_Color0_LIGHTGRAY() { return LIGHTGRAY; }
Color1 get_Color1_RED() { return RED; }
Color1 get_Color1_GREEN() { return GREEN; }
Color1 get_Color1_BLUE() { return BLUE; }
Color2 get_Color2_CYAN() { return CYAN; }
Color2 get_Color2_MAGENTA() { return MAGENTA; }
Color2 get_Color2_YELLOW() { return YELLOW; }
Color2 get_Color2_BLACK() { return BLACK; }
Color3 get_Color3_BROWN() { return BROWN; }
Color4 get_Color4_C4_BROWN() { return C4_BROWN; }

int intval(Color1 x) { return static_cast<int>(x); }
int intval_r(Color1& x) { return static_cast<int>(x); }
int intval_p(Color1* x) { return static_cast<int>(*x); }
int intval_cr(Color1 const& x) { return static_cast<int>(x); }
int intval_cp(Color1 const* x) { return static_cast<int>(*x); }

int intval(Color3 x) { return static_cast<int>(x); }
int intval_r(Color3& x) { return static_cast<int>(x); }
int intval_p(Color3* x) { return static_cast<int>(*x); }
int intval_cr(Color3 const& x) { return static_cast<int>(x); }
int intval_cp(Color3 const* x) { return static_cast<int>(*x); }
}

%{
static Color0 Color0_const1 = GRAY;
static Color0 Color0_const2 = LIGHTGRAY;
static Color1 Color1_const1 = RED;
static Color1 Color1_const2 = GREEN;
static Color1 Color1_const3 = BLUE;
static Color2 Color2_const1 = CYAN;
static Color2 Color2_const2 = MAGENTA;
static Color2 Color2_const3 = YELLOW;
static Color2 Color2_const4 = BLACK;
static Color3 Color3_const1 = BROWN;
static Color4 Color4_const1 = C4_BROWN;
%}

%constant Color0 Color0_const1;
%constant Color0 Color0_const2;
%constant Color1 Color1_const1;
%constant Color1 Color1_const2;
%constant Color1 Color1_const3;
%constant Color2 Color2_const1;
%constant Color2 Color2_const2;
%constant Color2 Color2_const3;
%constant Color2 Color2_const4;
%constant Color3 Color3_const1;
%constant Color4 Color4_const1;
