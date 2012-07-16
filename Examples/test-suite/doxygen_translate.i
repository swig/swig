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
 * \example someFile.txt
 * Some details on using the example
 * 
 * \exception SuperError
 * 
 * \if ANOTHERCONDITION
 *   First part of comment
 *   \if SECONDCONDITION
 *     Nested condition text
 *   \elseif THIRDCONDITION
 *     The third condition text
 *   \else
 *     The last text block
 *   \endif
 * \else
 *   Second part of comment
 *   \if CONDITION
 *     Second part extended
 *   \endif
 * \endif
 * 
 * \ifnot SOMECONDITION
 *   This is printed if not
 * \endif
 * 
 * \image html testImage.bmp "Hello, world!" asd=10qwe
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
 * \note Here
 * is the note!
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
