%module namespace_extend

%warnfilter(SWIGWARN_RUBY_WRONG_NAME) bar; /* Ruby, wrong class name */

%{
namespace foo {
   class bar {
   public:
   };
}
%}

// C uses different naming convention, with all functions starting with the class prefix.
#ifdef SWIGC
%{
foo::bar *foo_bar_new() {
   return new foo::bar;
}
void     foo_bar_delete(foo::bar *self) {
   delete self;
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
%}
#endif

%{
int foo_bar_blah(foo::bar *self, int x) {
   return x;
}
%}

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



