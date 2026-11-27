%module namespace_enum

%inline %{

namespace Foo {
   enum Beer {
       LAGER,
       STOUT,
       ALE
    };

   class Bar {
   public:
        enum Speed {
            SLOW,
            FAST
        };
   };
}

%}

       
   