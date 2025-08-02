%module doxygen_parsing

%inline %{

/**
 * The class comment
 */
class SomeClass
{
};

/**
 * The function comment
 */
void someFunction()
{
}

/**
 * The enum comment
 */
enum SomeEnum
{
	SOME_ENUM_ITEM
};

/**
 * The struct comment
 */
struct SomeStruct
{
   int width; ///< \**immutable** image width in pixels
};

/**
 * The var comment
 */
int someVar=42;

/**
 * The constant comment
 */
#define CONSTANT_VALUE 4242

/**
 * A two line
 * constant comment
 */
#define CONSTANT_VALUE_TWO_LINE 5353

/// SomeAnotherClass description
class SomeAnotherClass
{
public:
	/// First overloaded constructor.
	SomeAnotherClass(int) { }

	/// Second overloaded constructor.
	SomeAnotherClass(const char*) { }


	/**
	 * The class attribute comment
	 */
	int classAttr;

	int classAttr2; ///< The class attribute post-comment

	int classAttr3; ///< The class attribute post-comment
									//!< with details

	/**
	 * The class attribute comment with
	 * two lines of comments
	 */
	int classAttr4;

	/**
	 * The class method comment.
         *
         * \link SomeAnotherClass#classMethodExtended(int, int) a link text \endlink
	 */
	void classMethod()
	{
	}

	/**
	 * The class method with parameter
	 */
	void classMethodExtended(
			int a, ///< Parameter a
			int b  ///< Parameter b
			)
	{
	}

	/**
	 * The class method with parameter
	 *
	 * @param a Parameter a
	 * @param b Parameter b
	 */
	void classMethodExtended2(int a, int b)
	{
	}
};

struct SomeAnotherStruct
{
	/**
	 * The struct attribute comment
	 */
	int structAttr;

	int structAttr2; ///< The struct attribute post-comment

	int structAttr3; ///< The struct attribute post-comment
									 //!< with details

	/**
	 * The struct attribute comment with
	 * two lines of comments
	 */
	int structAttr4;

	/**
	 * The struct method comment
	 */
	void structMethod()
	{
	}

	/**
	 * The struct method with parameter
	 */
	void structMethodExtended(
			int a, ///< Parameter a
			int b  ///< Parameter b
			)
	{
	}

	/**
	 * The struct method with parameter
	 *
	 * @param a Parameter a
	 * @param b Parameter b
	 */
	void structMethodExtended2(int a, int b)
	{
	}

	/**
	 * The struct static method one line comment
	 */
	static void structStaticMethod(int xxx, int yyy)
	{
	}

	/**
	 * The struct static method with parameters
	 * Two lines of comments
	 *
	 * @param aaa Parameter aaa
	 * @param bbb Parameter bbb
	 */
	static void structStaticMethod2(int aaa, int bbb)
	{
	}
};

struct Foo1636
{
  ///@{
  /// groupmember1 description
  int groupmember1;
  /// groupmember2 description
  int groupmember2;
  ///@}
};

struct Foo1750
{
  /// @name Group name
  /// @{
  int a;
  /// @}
  int b;
};

#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif
%}
