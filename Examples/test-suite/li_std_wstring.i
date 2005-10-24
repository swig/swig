%module li_std_wstring
%include <std_wstring.i>


%inline %{

typedef std::wstring A;

struct B 
{
  B(const std::wstring& s) : cname(0), name(s), a(s)
  {
  }
  
  char *cname;
  std::wstring name;
  A a;

};
 

wchar_t test_wcvalue(wchar_t x) {
   return x;
}

const wchar_t* test_ccvalue(const wchar_t* x) {
   return x;
}

wchar_t* test_cvalue(wchar_t* x) {
   return x;
}
  

std::wstring test_value(std::wstring x) {
   return x;
}

const std::wstring& test_const_reference(const std::wstring &x) {
   return x;
}

void test_pointer(std::wstring *x) {
}

std::wstring *test_pointer_out() {
   static std::wstring x = L"x";
   return &x;
}

void test_const_pointer(const std::wstring *x) {
}

const std::wstring *test_const_pointer_out() {
   static std::wstring x = L"x";
   return &x;
}

void test_reference(std::wstring &x) {
}

std::wstring& test_reference_out() {
   static std::wstring x = L"x";
   return x;
}

void test_throw() throw(std::wstring){
  static std::wstring x = L"x";
  
  throw x;
}

%}


