%module nested_scope

#if !defined(SWIGCSHARP) && !defined(SWIGJAVA)
%feature ("flatnested");
#endif

%inline %{
namespace ns {
	struct Global {
		struct Outer {
			struct Nested;
		};
		struct Outer::Nested {
			int data;
		} instance;
	};
}
%}