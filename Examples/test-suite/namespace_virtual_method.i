%module namespace_virtual_method

%warnfilter(515);

#ifdef SWIGTYPESCRIPT
/* TypeScript tracks all type definitions and will correctly report the name collision for Foo */
%rename(Foo2) A::B::Foo;
#endif


%inline %{

namespace A {
   namespace B {
       class Foo;
   }
   namespace C {
       class Foo {
	public:
           Foo() { };
           virtual ~Foo() { };
           virtual int bar(const A::B::Foo &x) = 0;
       };
   }
}

namespace A {
   namespace C {
        class Spam : public Foo {
	public:
            Spam() { }
            virtual ~Spam() { }
            virtual int bar(const B::Foo &x) { return 1; }
        };
   }
}

%}

%{
namespace A {
   namespace B {
         class Foo { };
   }
}
%}
