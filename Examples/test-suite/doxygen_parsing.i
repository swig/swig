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
};

/**
 * The var comment
 */
int someVar=42;

/**
 * The constant comment
 */
#define CONSTANT_VALUE 4242

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
};

#ifdef SWIGPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif
%}
