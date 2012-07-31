%module cpp_basic_class_virtual_method

%inline %{
	class BaseClass {
	public:
		virtual int myInt(void) {
			return 0xba53;
		}
	};

	class NonMethodOverwritingClass : public BaseClass{
	};

	class MethodOverwritingClass : public BaseClass{
	public:
		virtual int myInt(void) {
			return 0xa173123d;
		}
	};
%}