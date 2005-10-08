%module(ruby_minherit="1") using_namespace

%warnfilter(801) hi::hi0;	/* Ruby, wrong class name */
%warnfilter(801) hi::hi1;	/* Ruby, wrong class name */

%warnfilter(813,833,870) Hi<hello::Hello, hi::hi0>; // C#, Java, Php4 multiple inheritance

%inline %{
  namespace hello
  {  
    struct Hello 
    {
    };

    template <class _T1, class _T2>
    struct Hi : _T1, _T2
    {
      int value1() const
      {
	return 1;
      }      

      int value2() const
      {
	return 2;
      }      
    };    
  }

  namespace hi
  {

    struct hi0
    {
    };
    
  }
%}

namespace hello
{
  %template(Hi_hi0) Hi<hello::Hello, hi::hi0>;
}


%inline %{
  namespace hi
  {
    struct hi1 : private hello::Hi< hello::Hello, hi0 >
    {
      using hello::Hi< hello::Hello, hi::hi0 >::value1;
      using hello::Hi< hello::Hello, hi0 >::value2;
    };
    
  }
  
%}
