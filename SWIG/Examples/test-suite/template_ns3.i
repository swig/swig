%module template_ns3

%inline %{
namespace foo {
   typedef int Integer;

   template<class T> class bar {
   public:
       Integer test(Integer x) { return x; }
   };

}
%}

%template(bari) foo::bar<int>;

   
    

