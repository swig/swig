%module li_std_string
%include <std_basic_string.i>
%include <std_string.i>

%template(string) std::basic_string<char>;
%inline %{

struct A : std::string 
{
  A(const std::string& s) : std::string(s)
  {
  }
};

struct B 
{
  B(const std::string& s) : cname(0), name(s), a(s)
  {
  }
  
  char *cname;
  std::string name;
  A a;

};
 

const char* test_ccvalue(const char* x) {
   return x;
}

char* test_cvalue(char* x) {
   return x;
}
  

std::string test_value(std::string x) {
   return x;
}

const std::string& test_const_reference(const std::string &x) {
   return x;
}

void test_pointer(std::string *x) {
}

std::string *test_pointer_out() {
   static std::string x = "x";
   return &x;
}

void test_const_pointer(const std::string *x) {
}

const std::string *test_const_pointer_out() {
   static std::string x = "x";
   return &x;
}

void test_reference(std::string &x) {
}

std::string& test_reference_out() {
   static std::string x = "x";
   return x;
}

void test_throw() throw(std::string){
  static std::string x = "x";
  
  throw x;
}

%}


