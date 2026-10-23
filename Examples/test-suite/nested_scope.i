%module nested_scope

// For target languages that do not support nested classes these are reported with Warning 325
// (and the nested template %template with Warning 331). This test only checks that the various out
// of scope and out of line nested class definitions are parsed without error.
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) ns::Global_::Outer;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) ns::Global_::Outer::Nested;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Outer1::Nested2;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS,SWIGWARN_PARSE_TEMPLATE_NESTED) Klass::AbstractClass;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) Klass::Real;
%warnfilter(SWIGWARN_PARSE_NAMED_NESTED_CLASS) protectedbase::ProtectedNestedOuter::ProtectedNestedDerived;

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
			template <class T> class AbstractClass;
			class Real;
		};
#ifndef __clang__
		struct Outer1::Nested2 {
			int data;
		};
#endif
		
		class Klass {
		public:
			template <class T> class AbstractClass;
			class Real;
		};

		template <class T> class Klass::AbstractClass {
		public:
			virtual void Method() = 0;
			virtual ~AbstractClass() {}
		};
%} 

%template(abstract_int) Klass::AbstractClass <int>;

%inline %{
		class Klass::Real : public AbstractClass <int> {
		public:
			virtual void Method() {}
		};
%}

// A protected nested class deriving from a publicly used base class - used to generate an illegal
// upcast helper naming the class by its inaccessible qualified name.
%inline %{
namespace protectedbase {
	class ProtectedNestedBase {
	public:
		virtual ~ProtectedNestedBase() {}
	};

	class ProtectedNestedOuter {
	protected:
		class ProtectedNestedDerived : public ProtectedNestedBase {
		public:
			ProtectedNestedDerived() {}
		};
	public:
		virtual ~ProtectedNestedOuter() {}
		virtual ProtectedNestedBase *makeDerived() { return new ProtectedNestedDerived(); }
	};
}
%}
