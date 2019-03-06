%module rename_qualified

#if defined(SWIGPERL)
// Java really does not like this, I assume it will choke others too
%rename("%(regex:/^Old(\\S+)$/New::\\1/)s") "";
#endif

%inline %{
struct OldStruct {
  enum { ONE = 1, TWO, THREE };
  OldStruct() : InstanceVariable(111) {}
  int InstanceVariable;
  int InstanceMethod() { return 222; }
  static int StaticVariable;
  static int StaticMethod() { return 333; }
};
int OldStruct::StaticVariable = 444;

int OldFunction() { return 555; }
int OldGlobalVariable = 666;
#define OldMacro 777
%}
