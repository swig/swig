%module namespace_nested

%inline %{
  namespace hello
  {  
    namespace hi
    {      
      struct hi0
      {
      };      
    }

    template <class _T1>
    struct Hi : _T1
    {
    };
  }

%}

namespace hello
{
  %template(Hi_hi0) Hi<hi::hi0>;
}


%inline %{

  namespace hello
  {
    //
    // This works 
    //
    // typedef Hi<hello::hi::hi0> Hi0;
    
    //
    // This doesn't work
    //
    typedef Hi<hi::hi0> Hi0;
  };
  
  
  namespace oss
  {
    template <class _T>
    struct hi1 : _T
    {
    };    
  }
  
%}

namespace oss
{
  %template(hi1_hi0) hi1<hello::Hi0 >;
}
