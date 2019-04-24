%module doxygen_translate

#if defined(SWIGJAVA)
%javamethodmodifiers function "@Deprecated\npublic"
#endif

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
 * \image html testImage.bmp "Hello, world!" width=10cm
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
    return 0;
}

/**
 * Test for html tags. See Doxygen doc for list of tags recognized by Doxygen.
 *
 * <a href="http://acme.com/index.html">This is link</a>
 * <b>bold</b>
 * <BLOCKQUOTE cite="http://www.worldwildlife.org/who/index.html">
 * Quotation block.
 * </BLOCKQUOTE>
 * <br>
 * <center>center</center>
 * <code>this is code</code>
 *
 * <DL>
 * <DT>Starts an item title.</DT>
 * <DD>Starts an item description.</dd>
 * </dl>
 *
 * <DFN>Starts a piece of text displayed in a typewriter font.
 * </DFN>
 * <DIV>Starts a section with a specific style (HTML only)
 * </DIV>
 * <EM>Starts a piece of text displayed in an italic font.</EM>
 *
 * <FORM>'Form' does not generate any output.
 * </FORM>
 * <HR>
 * <H1>Heading 1
 * </H1>
 * <H2>Heading 2
 * </H2>
 * <H3>Heading 3
 * </H3>
 * <I>Starts a piece of text displayed in an italic font.</I>
 * <INPUT>Input tag.
 * <IMG src="slika.png"> 
 * <META>Meta tag.
 * <MULTICOL>Multicol is ignored by doxygen.
 * </MULTICOL>
 *
 * <OL>
 * <LI>List item 1.</LI>
 * <LI>List item 2.</LI>
 * </OL>
 *
 * <P>Starts a new paragraph.
 * </P>
 * <PRE>Starts a preformatted fragment.
 * </PRE>
 * <SMALL>Starts a section of text displayed in a smaller font.
 * </SMALL>
 * <SPAN>Starts an inline text fragment with a specific style.</SPAN>
 * <STRONG>Starts a section of bold text.</STRONG>
 * <SUB>Starts a piece of text displayed in subscript.</SUB>
 * <SUP>Starts a piece of text displayed in superscript.</SUP>
 *
 * <table border = '1'>
 * <caption>Animals</caption>
 * <tr><th> Column 1 </th><th> Column 2 </th></tr>
 * <tr><td> cow      </td><td> dog      </td></tr>
 * <tr><td> cat      </td><td> mouse    </td></tr>
 * <tr><td> horse    </td><td> parrot   </td></tr>
 * </table>
 *
 * <TT>Starts a piece of text displayed in a typewriter font.
 * </TT>
 * <KBD>Starts a piece of text displayed in a typewriter font.
 * </KBD>
 *
 * <UL>
 * <LI>List item 1.</LI>
 * <LI>List item 2.</LI>
 * <LI>List item 3.</LI>
 * </UL>
 *
 * <VAR>Starts a piece of text displayed in an italic font.</VAR>
 *
 * \htmlonly
 * <u>underlined \b bold text - doxy commands are ignored inside 'htmlonly' section </u>
 * \endhtmlonly
 */
void htmlFunction(int a, float b)
{
}

/** 
 * The meaning of flags:
 *
 * @param byFlags bits marking required items:
 *   <table>
 *   <tr><th> Size in bits</th><th> Items Required </th></tr>
 *   <tr><td> 1 - 8       </td><td>      1         </td></tr>
 *   <tr><td> 9 - 16      </td><td>      2         </td></tr>
 *   <tr><td> 17 - 32     </td><td>      4         </td></tr>
 *   </table>
 *   Almost all combinations of above flags are supported by
 *   \c htmlTable... functions.
 */
void htmlTableFunction(int byFlags)
{
}


/**
 * All entities are treated as commands &copy; &trade; &reg;
 * should work also&lt;in text
 * &gt;
 * &amp;
 * &apos;
 * &quot;
 * &lsquo;
 * &rsquo;
 * &ldquo;
 * &rdquo;
 * &ndash;
 * &mdash;
 * &nbsp;
 * &times;
 * &minus;
 * &sdot;
 * &sim;
 * &le;
 * &ge;
 * &larr;
 * &rarr;
 * Not an &text; html entity - ignored by Doxygen.
 * Not an &text html entity - ampersand is replaced with entity.
 */
void htmlEntitiesFunction(int a, float b)
{
}


 
%}
