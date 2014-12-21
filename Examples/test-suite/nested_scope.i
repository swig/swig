%module nested_scope

#if !defined(SWIGCSHARP) && !defined(SWIGJAVA)
%feature ("flatnested");
#endif

%inline %{
namespace ns {
        // "global" is a case-insensitive keyword in PHP.
	struct Global_ {
#ifdef __clang__
		struct Outer {
			struct Nested;
			struct Nested {
			  int data;
			};
		};
		struct Outer::Nested instance;
#else
		struct Outer {
			struct Nested;
		};
		struct Outer::Nested {
			int data;
		} instance;
#endif
	};
}
		class Outer1 {
			struct Nested1;
		public:
			struct Nested2;
#ifdef __clang__
		struct Nested2 {
			int data;
		};
#endif
			template <class T> class Abstract;
			class Real;
		};
#ifndef __clang__
		struct Outer1::Nested2 {
			int data;
		};
#endif
		
		class Class {
		public:
			template <class T> class Abstract;
			class Real;
		};

		template <class T> class Class::Abstract {
		public:
			virtual void Method() = 0;
			virtual ~Abstract() {}
		};
%} 

%template(abstract_int) Class::Abstract <int>;

%inline %{
		class Class::Real : public Abstract <int> {
		public:
			virtual void Method() {}
		};
%}
