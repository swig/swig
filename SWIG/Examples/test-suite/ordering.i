%module ordering

// Ruby used to fail on the ordering of the two Class declarations below

struct Class {
  int variable;
};

%{
struct Class {
  int variable;
};
%}


// Testing the order of various code block sections

%runtime %{
   class RuntimeSection {};
%}

%header %{
   class HeaderSection {};
   void HeaderMethod(RuntimeSection rs) {}
%}

%wrapper %{
   void WrapperMethod(HeaderSection hs, RuntimeSection rs) {}
%}

