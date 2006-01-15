%module naming

%predicate predicateMethod();
%bang bangMethod();


/* This gets mapped to a constant */
%constant bool constant1 = false;

%immutable TestConstants::constant4;


%inline %{

/* ============  Test Constants Names ============== */
typedef enum {One, Two, Three, Four, Five} finger;
const char BeginString_FIX44a[8] = "FIX.a.a"; 

class TestConstants {
public:
	/* This gets mapped to a constant */
 	static const int constant2 = 1;
  const char *constant3;
  const char *constant4;
};

const TestConstants * constant4[5];
const int constant5[2] = {10, 20};


/* ============  Test Method Names ============== */
class my_class {
public:
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