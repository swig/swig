// Based on https://github.com/swig/swig/issues/339 .

%module inherit_member

%include <std_string.i>

%inline %{

struct parent {
  std::string pvar;
};

 struct child : public parent {
  std::string cvar;
};

%}
