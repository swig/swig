%module namespace_extend

%warnfilter(SWIGWARN_RUBY_WRONG_NAME) bar; /* Ruby, wrong class name */

%{
namespace foo {
   class bar {
   public:
   };
}
%}

// C uses different naming convention, with all functions starting with the class prefix
// and using the global namespace prefix too, if specified (which is the case for the tests).
#ifdef SWIGC
%{
foo::bar *namespace_extend_foo_bar_new() {
   return new foo::bar;
}
void     namespace_extend_foo_bar_delete(foo::bar *self) {
   delete self;
}

int namespace_extend_foo_bar_blah(foo::bar *self, int x) {
   return x;
}
%}
#else
%{
foo::bar *new_foo_bar() {
   return new foo::bar;
}
void     delete_foo_bar(foo::bar *self) {
   delete self;
}

int foo_bar_blah(foo::bar *self, int x) {
   return x;
}
%}
#endif

namespace foo {
    class bar {
    public:
    %extend {
        bar();
       ~bar();
        int blah(int x);
    };
  };
}



