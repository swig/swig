%module exception_partial_info

// This produced compileable code for Tcl, Python in 1.3.27, fails in 1.3.29

%{
class myException
{
   public:
      virtual const char *name() = 0;
};

class ex1 : public myException
{
   public:
      virtual const char *name() { return "ex1"; }
};

class ex2 : public myException
{
   public:
      virtual const char *name()  { return "ex2"; }
};
%}

%inline %{
class impl
{
   public:
      void f1() throw (myException) { ex1 e; throw e; }
      void f2() throw (myException) { ex2 e; throw e; }
};
%}

