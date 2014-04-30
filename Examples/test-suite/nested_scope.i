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
%}
