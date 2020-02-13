%module(directors="1") director_conversion_operators

%feature("director");

%warnfilter(SWIGWARN_TYPEMAP_DIRECTOROUT_PTR) Bar;

%rename(toFoo) Bar::operator Foo();
%rename(toFooPtr) Bar::operator Foo *();
%rename(toFooRef) Bar::operator Foo &();
%rename(toFooPtrRef) Bar::operator Foo *&();

%rename(toOtherFoo) Bar::operator OtherFoo();
%rename(toOtherFooPtr) Bar::operator OtherFoo *();
%rename(toOtherFooRef) Bar::operator OtherFoo &();
%rename(toOtherFooPtrRef) Bar::operator OtherFoo *&();

%inline %{
   struct Foo {
   };
   struct OtherFoo {
   };
   struct Bar {
      Foo myFoo;
      Foo *myFooPtr;
      virtual ~Bar() { }
      virtual operator Foo () { return Foo(); }
      virtual operator Foo *() { return &myFoo; }
      virtual operator Foo &() { return myFoo; }
      virtual operator Foo *&() { return myFooPtr; }
      virtual operator OtherFoo () = 0;
      virtual operator OtherFoo *() = 0;
      virtual operator OtherFoo &() = 0;
      virtual operator OtherFoo *&() = 0;
   };
%}
