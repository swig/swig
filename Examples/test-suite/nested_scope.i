%module nested_scope

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