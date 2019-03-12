

%module doxygen_translate_links
%include "std_string.i"

%inline %{

class Shape
{
public:
  typedef Shape* superType;
};

/**
 * Testing typenames converting in \@ link
 *
 * \link superFunc(int,std::string)
 * Test for std_string member
 * \endlink
 *
 * \link superFunc(int,long,void*)
 * Test for simple types
 * \endlink
 *
 * \link superFunc(Shape::superType*)
 * Test for custom types
 * \endlink
 * 
 * \link superFunc(int**[13])
 * Test for complex types
 * \endlink
 * 
 * same works for 'See also:' links:
 *
 * \sa superFunc(int,std::string)
 * \sa superFunc(int,long,void*)
 * \sa superFunc(Shape::superType*)
 * \sa superFunc(int**[13])
 * 
 * some failing params:
 *
 * \sa superFunc()
 * \sa superFunc()
 * \sa superFunc()
 *
 */
void function()
{
}

void superFunc(int, std::string)
{
}

void superFunc(int, long, void *)
{
}

void superFunc(Shape::superType *)
{
}

void superFunc(int **arr[13])
{
}

%}
