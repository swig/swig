%module typemap_isvoid

%{
void abc_1() {}
void def_0() {}
%}

// Use %exception to make sure $isvoid is expanded in the wrapper function
%exception void_function %{
$action
abc_$isvoid(); // must expand to abc_1
%}

%exception nonvoid_function %{
$action
def_$isvoid(); // must expand to def_0
%}

%exception void_function_static %{
$action
abc_$isvoid(); // must expand to abc_1
%}

%exception nonvoid_function_static %{
$action
def_$isvoid(); // must expand to def_0
%}

%exception AStruct::AStruct %{ $action
def_$isvoid(); // constructor must expand to def_0
%}

%exception AStruct::~AStruct %{
$action
abc_$isvoid(); // destructor must expand to abc_1
%}

%inline %{
void void_function() {}
int nonvoid_function() { return 0; }
void*nonvoid_function_voidptr() { return 0; }
struct AStruct {
  void void_function() {}
  int nonvoid_function() { return 0; }
  void* nonvoid_function_voidptr() { return 0; }
  static void void_function_static() {}
  static int nonvoid_function_static() { return 0; }
  static void* nonvoid_function_static_voidptr() { return 0; }

  AStruct() {}
  ~AStruct() {}
};
%}

// Use the ret and check typemaps to make sure $isvoid is expanded in at least these typemaps
%typemap(check) int forvoid %{ abc_$isvoid(); /* must expand to abc_1() in a void return function (check typemap) */ %}
%typemap(check) int fornonvoid %{ def_$isvoid(); /* must expand to def_0() in a non void return function (check typemap) */ %}
%typemap(ret) void %{ abc_$isvoid(); /* must expand to abc_1() in a void return function (ret typemap $1_type) */ %}
%typemap(ret) long, void* %{ def_$isvoid(); /* must expand to def_0() in a non void return function (ret typemap $1_type) */ %}

%inline %{
void test_isvoid(int forvoid) {}
long test_nonvoid(int fornonvoid) { return 0; }
void* test_nonvoid_voidptr(int fornonvoid) { return 0; }
struct TestVoid {
  void test_isvoid(int forvoid) {}
  long test_nonvoid(int fornonvoid) { return 0; }
  void* test_nonvoid_voidptr(int fornonvoid) { return 0; }
  static void test_isvoid_static(int forvoid) {}
  static long test_nonvoid_static(int fornonvoid) { return 0; }
  static void* test_nonvoid_static_voidptr(int fornonvoid) { return 0; }
};
%}
