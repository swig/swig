%module template_arg_scope
%inline %{

template<class T> class Foo {
};

class Bar {
public:
   Bar();
   void spam(Foo<Bar> *x);
};

%}

