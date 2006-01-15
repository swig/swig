%module naming

%predicate predicateMethod();
%bang bangMethod();

%inline %{


class my_class {
public:
	static const int const1 = 1;
	
	my_class() {}
	
	int methodOne()
	{
		return 1;
	}
	
  int MethodTwo()
	{
		return 2;
	}
	
  int Method_THREE()
	{
		return 3;
	}

  int Method44_4()
	{
		return 4;
	}
	
  bool predicateMethod()
	{
		return true;
	}
	
  bool bangMethod()
	{
		return true;
	}
};

%}