/* This tests setting the C# namespace via the 'namespace' option of the %module
   directive in the interface file, instead of the -namespace commandline option.
   See GitHub issue #3495.

   The C# test-suite normally passes -namespace <testcase>Namespace on the
   commandline to every testcase; the Makefile clears that option for this
   testcase (target-specific CSHARP_NAMESPACE_OPT) so that the namespace set
   here via %module is the one actually used. */

%module(namespace="SwigModuleNamespace") csharp_module_namespace

%inline %{
int add(int a, int b) { return a + b; }

class Number {
  int val;
public:
  Number(int v) : val(v) {}
  int get() const { return val; }
};
%}
