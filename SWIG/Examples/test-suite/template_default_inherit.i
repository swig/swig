%module template_default_inherit
 
%inline %{
  template <class C>
    struct A
    {
      typedef unsigned int size_type;
      static const size_type nindex = static_cast<size_type>(-1);
 
    };
 
    template <class C>
    struct B : A<C>
    {
      typedef typename A<C>::size_type size_type;
      void say_hi(size_type index = nindex);
    };
 
%}
 
%template(A_int) A<int>;
%template(B_int) B<int>;                

