%module doxygen_translate_all_tags

#if defined(SWIGJAVA)
%javamethodmodifiers func02 "@Deprecated\npublic"
#endif

%inline %{

/**
 * \a Hello
 * 
 * \addindex SomeLatexIndex
 *
 * \addtogroup someGroup "Some title"
 *
 * \anchor theAnchor
 *
 * \arg some list item
 * 
 * \attention This is attention!
 * You were warned!
 *
 * \authors lots of them
 * \author Zubr
 * 
 * \b boldword
 * 
 * \brief Some brief description,
 * extended to many lines.
 *
 * \bug Not everything works right now...
 * \c codeword
 * 
 * \callgraph
 * \callergraph
 * \category someCategory headerFile.h headerName
 *
 * \cite citationword
 * \class someClass headerFile.h headerName
 * \code some test code \endcode
 *
 * Code immediately following text.  Pydoc translation must add an
 * empty line before:
 * \code more test code \endcode
 */
void func01(int a)
{
}

 
/** 
 * \cond SOMECONDITION
 * Some conditional comment
 * \endcond
 * 
 * \copybrief someClass::someMethod
 *
 * \copydetails someClass::someMethod2
 *
 * \copydoc  someClass::someMethod3
 *
 * \copyright some copyright
 * 
 * \date 1970 - 2012
 *
 * \def someDefine
 *
 * \defgroup someGroup Some titles
 *
 * \deprecated Now use another function
 * 
 * \details This is very large
 * and detailed description of some thing
 */
void func02(int a)
{
}

 
/**
 * Comment for \b func03().
 *
 * \dir /somePath/someFolder
 *
 * \dontinclude someFile.h
 *
 * \dot
 * digraph example {
 * node [shape=record, fontname=Helvetica, fontsize=10];
 * b [ label="class B" URL="\ref B"];
 * c [ label="class C" URL="\ref C"];
 * b -> c [ arrowhead="open", style="dashed" ];
 * }
 * \enddot
 *
 * \dotfile dotFile.dot "The caption"
 *
 * \e italicword
 * 
 * \em emphazedWord
 *
 * \enum someEnum
 *
 * \example someFile.txt
 * Some details on using the example
 */
void func03(int a)
{
}

 
/**
 * 
 * \exception SuperError
 * 
 * \extends someOtherFunction
 *
 * \f$ \sqrt{(x_2-x_1)^2+(y_2-y_1)^2} \f$
 *
 * \f[
 *     \sqrt{(x_2-x_1)^2+(y_2-y_1)^2}
 * \f]
 *
 * \f{
 *     \sqrt{(x_2-x_1)^2+(y_2-y_1)^2}
 * \f}
 *
 * Math immediately following text.  Pydoc translation must add an
 * empty line before:
 * \f[
 *     \sqrt{(x_2-x_1)^2+(y_2-y_1)^2}
 * \f]
 *
 * \file file.h
 *
 * \fn someFn
 *
 * \headerfile someHeader.h "Header name"
 *
 * \hideinitializer
 *
 * \htmlinclude htmlFile.htm
 *
 * \htmlonly
 * This will only appear in hmtl
 * \endhtmlonly
 */
void func04(int a)
{
}

 
/**
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
 * \implements someFunction
 *
 * \include header.h
 *
 * \includelineno header2.h
 *
 * \ingroup someGroup anotherGroup
 *
 * \internal
 *
 * \invariant Some text
 * describing invariant.
 */
void func05(int a)
{
}

 
/**
 * Comment for \b func06().
 *
 * \interface someInterface someHeader.h "Header name"
 *
 * \latexonly
 * This will only appear in LATeX
 * \endlatexonly
 *
 * <ul>
 * 
 * \li Some unordered list
 * \li With lots of items
 * \li lots of lots of items
 * 
 * </ul>
 * 
 * \line example
 *
 * \link someMember Some description follows\endlink with text after
 * 
 * \mainpage Some title
 *
 * \manonly
 * This will only appear in man
 * \endmanonly
 *
 * \memberof someThing
 *
 * \msc
 * Sender,Receiver;
 * Sender->Receiver [label="Command()", URL="\ref Receiver::Command()"];
 * Sender<-Receiver [label="Ack()", URL="\ref Ack()", ID="1"];
 * \endmsc
 *
 * \mscfile mscFile.msc "The caption"
 *
 * \n \n \n
 */
void func06(int a)
{
}

 
/**
 * Comment for \b func07().
 *
 * \name someHeader.h
 *
 * \namespace someNamespace
 *
 * \nosubgrouping
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
 * \page somePage The title
 *
 * \par The paragraph title
 * The paragraph text.
 * Maybe even multiline
 * 
 * \paragraph someParagraph Paragraph title
 *
 * \param a the first param
 * \param[in] b parameter with intent(in)
 * \param[out] c parameter with intent(out)
 * \param[in,out] d parameter with intent(in,out)
 * 
 * \post Some description
 *
 * \pre Some description
 *
 * \private
 *
 * \privatesection
 *
 * \property someVar
 */
void func07(int a, int b, int c, int d)
{
}

 
/**
 * \protected
 *
 * \protectedsection
 *
 * \anchor someAnchor
 * Text after anchor.
 * \protocol someProtocol header.h "Header name"
 *
 * \public
 *
 * \publicsection
 *
 * \ref someAnchor "Anchor description"
 *
 * \ref someAnchor not quoted text is not part of ref tag
 *
 * \ref someAnchor
 *
 * \related toSomething
 *
 * \relates toSomethingElse
 *
 * \relatedalso someName
 *
 * \relatesalso someName
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
 * \retval someValue Some description
 */
void func08(int a)
{
}

 
/**
 * \rtfonly
 * This will only appear in RTF
 * \endrtfonly
 *
 * \sa someOtherMethod
 * 
 * \section someSection Some title
 *
 * \see function
 * 
 * \short Same as
 * brief description
 *
 * \showinitializer
 *
 * \since version 0.0.0.1
 * 
 * \skip somePattern
 *
 * \skipline someLine
 *
 * \snippet example.h Some snippet
 *
 * \struct someStruct
 *
 * \subpage someSubpage "Some description"
 *
 * \subsection someSubsection Some title
 *
 * \subsubsection someSubsection Some title
 *
 * \tableofcontents
 *
 * \test Some
 * description of the
 * test case
 *
 * \throw superException
 * 
 * \throws RuntimeError
 */
void func09(int a)
{
}

 
/**
 * \todo Some very important task
 * 
 * \tparam b B is mentioned again...
 * 
 * \typedef someTypedef
 *
 * \union someUnion
 *
 * \until somePattern
 *
 * \var someVar
 *
 * \verbatim
 * very long
 * text with tags <sometag>
 * \endverbatim
 * 
 * \verbinclude someFile.h
 *
 * \version 0.0.0.2
 * 
 * \warning This is senseless!
 * 
 * \weakgroup someGroup Some title
 *
 * \xmlonly
 * This will only appear in XML
 * \endxmlonly
 *
 * \xrefitem todo "Todo" "Todo List"
 *
 * Here goes test of symbols:
 * \$ \@ \\ \& \~ \< \> \# \% \" \. \::
 * 
 * And here goes simple text
 */
void func10(int a, float b)
{
}

%}
