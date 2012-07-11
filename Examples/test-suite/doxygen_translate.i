%module doxygen_translate

%inline %{

/**
 * \a Hello
 * 
 * \arg some list item
 * 
 * \authors lots of them
 * 
 * \author Zubr
 * 
 * \b boldword
 * 
 * \c codeword
 * 
 * \cite citationword
 * 
 * \code some test code \endcode
 * 
 * \cond SOMECONDITION
 * Some conditional comment
 * \endcond
 * 
 * \copyright some copyright
 * 
 * \deprecated Now use another function
 * 
 * \e italicword
 * 
 * \if ANOTHERCONDITION
 * 	First part of comment
 * \else
 * 	Second part of comment
 * \endif
 * 
 * \example someFile.txt
 * Some details on using the example
 * 
 * \exception SuperError
 * 
 * \ifnot CONDITION
 *  Write something if not
 * \endifnot
 * 
 * \image html testImage.bmp
 * 
 * <ul>
 * 
 * \li Some unordered list
 * \li With lots of items
 * \li lots of lots of items
 * 
 * </ul>
 * 
 * \link someMember Some description follows \endlink
 * 
 * \n \n \n
 * 
 * \overload
 * 
 * \p someword
 * 
 * \package superPackage
 * 
 * \par The paragraph title
 * The paragraph text.
 * Maybe even multiline
 * 
 * \param a the first param
 * 
 * \remark Some remark text
 * 
 * \remarks Another remarks section
 * 
 * \result Whatever
 * 
 * \return it
 * 
 * \returns may return
 * 
 * \sa someOtherMethod
 * 
 * \see function
 * 
 * \since version 0.0.0.1
 * 
 * \throw superException
 * 
 * \throws RuntimeError
 * 
 * \todo Some very important task
 * 
 * \tparam b B is mentioned again...
 * 
 * \verbatim
 * very long
 * text with tags <sometag>
 * \endverbatim
 * 
 * \version 0.0.0.2
 * 
 * \warning This is senseless!
 * 
 * Here goes test of symbols:
 * \$ \@ \\ \& \~ \< \> \# \% \" \. \::
 * 
 * And here goes simple text
 */
int function(int a, float b)
{
}

%}