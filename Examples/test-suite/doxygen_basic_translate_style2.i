%module doxygen_basic_translate_style2

%include "doxygen_basic_translate.h"

// This test demonstrates a doxygen comment style that starts on the
// first line and so uses extra spacing in subsequent lines.

%inline %{

/** \brief
 *  Brief description.
 * 
 *  The comment text.
 *
 *  \author Some author
 *
 *  \return Some number
 *
 *  \sa function2
 */
int function()
{
    return 0;
}

/** A test of a very very very very very very very very very very very very very very very very
 *  very very very very very long comment string.
 */
void function2()
{
}

/** A test for overloaded functions
 *  This is function \b one
 */
void function3(int a)
{
}

/** A test for overloaded functions
 *  This is function \b two
 */
void function3(int a, int b)
{
}

/** A test of some mixed tag usage
 *  \if CONDITION
 *  This \a code fragment shows us something \.
 *  \par Minuses:
 *  \arg it's senseless
 *  \arg it's stupid
 *  \arg it's null
 *
 *  \warning This may not work as expected
 *  \code
 *  int main() { while(true); }
 *
 *  // Test blank line in code block
 *  \endcode
 *  \endif
 */
void function4()
{
}


void function5(int a)
{
}
/**< This is a post comment. */

/** Test for default args
 *  @param a Some parameter, default is 42
 */
void function6(int a=42)
{
}

class Shape
{
public:
  typedef Shape* superType;
};

/** Test for a parameter with difficult type
 *  (mostly for python)
 *  @param a Very strange param
 */
void function7(Shape::superType *a[10])
{
}

/** Multiple parameters test.
 *
 *  @param y Vertical coordinate.
 *  @param x Horizontal coordinate.
 *  @return Arc tangent of @c y/x.
 */
double Atan2(double y, double x)
{
    return 0;
}

/** Comment at the end of file should be ignored.
 */
%}
