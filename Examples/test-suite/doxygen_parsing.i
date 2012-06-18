%module doxygen_parsing

%inline %{

/**
 * This is simple comment for a var
 */
int simpleVar=42;
/*!
 * This is another type of comment for a var
 */
int simpleVarTwo=42;

/// This is again another type of comment for a var
int simpleVarThree=42;
//! This is the last type of comment for a var
int simpleVarFour=42;

/*
  We assume that all this comment types are ok,
  and later we only use the first-type comments.
*/


/**
 * This is simple comment for a function
 */
void simpleFunction(int arg)
{
}

/**
 * This is simple comment for a class
 */
class CSimpleClass
{
private:
  /** Some member var */
  int simpleVar;

public:
  /** 
   * Simple method
   */
  void simpleMethod(int asd)
  {
  }
  /**
   * Simple method with parameter
   */
  void simpleMethodWithParameter(
	int param /**< Some test param */
	)
  {
  }
};

/**
 * Comment for template class
 */
template <typename T>
class CTemplateClass
{
public:
  /**
   * Template method
   */
  void templateMethod(T arg)
  {
  }
};

%}

%template(CTemplateClassInt) CTemplateClass<int>;