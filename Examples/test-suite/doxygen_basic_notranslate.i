%module doxygen_basic_notranslate

%include "doxygen_basic_translate.h"
%feature("doxygen:notranslate") function;
%feature("doxygen:notranslate") function1;
%feature("doxygen:notranslate") function2;
%feature("doxygen:notranslate") function3;
%feature("doxygen:notranslate") function4;
%feature("doxygen:notranslate") function5;
%feature("doxygen:notranslate") function6;
%feature("doxygen:notranslate") function7;

%inline %{

/**
 * \brief
 * Brief description.
 *
 * The comment text
 * \author Some author
 * \return Some number
 * \sa function2
 */
int function()
{
    return 0;
}

/** Single line comment */
void function1()
{
}

/**
 * A test of a very very very very very very very very very very very very very very very very
 * very very very very very long comment string.
 */
void function2()
{
}

/**
 * A test for overloaded functions
 * This is function \b one
 */
void function3(int a)
{
}

/**
 * A test for overloaded functions
 * This is function \b two
 */
void function3(int a, int b)
{
}

/**
 * A test of some mixed tag usage
 * \if CONDITION
 * This \a code fragment shows us something \.
 * \par Minuses:
 * \arg it's senseless
 * \arg it's stupid
 * \arg it's null
 *
 * \warning This may not work as expected
 *
 * \code
 * int main() { while(true); }
 * \endcode
 * \endif
 */
void function4()
{
}


void function5(int a)
{
}
/**< This is a post comment. */

/**
 * Test for default args
 * @param a Some parameter, default is 42
 */
void function6(int a=42)
{
}

class Shape
{
public:
  typedef Shape* superType;
};

/**
 * Test for a parameter with difficult type
 * (mostly for python)
 * @param a Very strange param
 */
void function7(Shape::superType *a[10])
{
}

/**
 * Comment at the end of file should be ignored.
 */
%}
