%module template_retvalue
%inline %{
 
  enum Hello
    {
      Hi, Hola
    };
 
  struct C
  {
      C(int);
  };
 
  template <Hello>
    class A
    {
    public:
      A(int);
    };
 
 
  template <Hello h>
    struct B
    {
      C get_c();               // this works
      A<h> get_a();         // this doesn't
    };
 
  %}
 
%template(A_Hi) A<Hi>;
%template(B_Hola) B<Hola>;                             
