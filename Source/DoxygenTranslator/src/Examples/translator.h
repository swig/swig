/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3 
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at http://www.swig.org/legal.html.
 *
 * translator.h
 * ----------------------------------------------------------------------------- */

#ifndef TRANSLATOR_H_
#define TRANSLATOR_H_

#define BRIEFDESCRIPTION       99
#define LONGDESCRIPTION        100
#define A_COMMAND              101  /* \a */
#define ADDINDEX               102  /* \addindex */
#define ADDTOGROUP             103  /* \addtogroup */
#define ANCHOR                 104  /* \anchor */
#define ARG_COMMAND            105  /* \arg */
#define ATTENTION              106  /* \attention */
#define AUTHOR                 107  /* \author */
#define B_COMMAND              108  /* \b */
#define BRIEF                  109  /* \brief */
#define BUG                    110  /* \bug */
#define C_COMMAND              111  /* \c */
#define CALLGRAPH              112  /* \callgraph */
#define CALLERGRAPH            113  /* \callergraph */
#define CATEGORY               114  /* \category */
#define CLASS_COMMAND          115  /* \class */
#define CODE                   116  /* \code */
#define COND                   117  /* \cond */
#define COPYBRIEF              118  /* \copybrief */
#define COPYDETAILS            119  /* \copydetails */
#define COPYDOC                120  /* \copydoc */
#define DATE                   121  /* \date */
#define DEF                    122  /* \def */
#define DEFGROUP               123  /* \defgroup */
#define DEPRECATED             124  /* \deprecated */
#define DETAILS                125  /* \details */
#define DIR_COMMAND            126  /* \dir */
#define DONTINCLUDE            127  /* \dontinclude */
#define DOT                    128  /* \dot */
#define DOTFILE                129  /* \dotfile */
#define E_COMMAND              130  /* \e */
#define ELSE_COMMAND           131  /* \else */
#define ELSEIF_COMMAND         132  /* \elseif */
#define EM                     133  /* \em */
#define ENDCODE                134  /* \endcode  */
#define ENDCOND                135  /* \endcond */
#define ENDDOT                 136  /* \enddot */
#define ENDHTMLONLY            137  /* \endhtmlonly  */
#define ENDIF                  138  /* \endif */
#define ENDLATEXONLY           139  /* \endlatexonly  */
#define ENDLINK                140  /* \endlink */
#define ENDMANONLY             141  /* \endmanonly */
#define ENDMSC                 142  /* \endmsc */
#define ENDVERBATIM            143  /* \endverbatim */
#define ENDXMLONLY             144  /* \endxmlonly */
#define ENUM                   145  /* \enum */
#define EXAMPLE                146  /* \example */
#define EXCEPTION              147  /* \exception */
#define FDOLLAR                148  /* \f$ */
#define FLEFTSQUAREBRACKET     149  /* \f[ */
#define FRIGHTSQUAREBRACKET    150  /* \f] */
#define FLEFTBRACKET           151  /* \f{ */
#define FRIGHTBRACKET          152  /* \f} */
#define FILE_COMMAND           153  /* \file */
#define FN_COMMAND             154  /* \fn */
#define HEADERFILE             155  /* \headerfile */
#define HIDEINITIALIZER        156  /* \hideinitializer */
#define HTMLINCLUDE            157  /* \htmlinclude */
#define HTMLONLY               158  /* \htmlonly */
#define IF_COMMAND             159  /* \if */
#define IFNOT_COMMAND          160  /* \ifnot */
#define IMAGE                  161  /* \image */
#define INCLUDE_COMMAND        162  /* \include */
#define INCLUDELINENO          163  /* \includelineno */
#define INGROUP                164  /* \ingroup */
#define INTERNAL               165  /* \internal */
#define INVARIANT              166  /* \invariant */
#define INTERFACE_COMMAND      167  /* \interface */
#define LATEXONLY              168  /* \latexonly */
#define LI                     169  /* \li */
#define LINE                   170  /* \line */
#define LINK                   171  /* \link */
#define MAINPAGE               172  /* \mainpage */
#define MANONLY                173  /* \manonly */
#define MSC                    174  /* \msc */
#define N                      175  /* \n */
#define NAME                   176  /* \name */
#define NAMESPACE              177  /* \namespace */
#define NOSUBGROUPING          178  /* \nosubgrouping */
#define NOTE                   179  /* \note */
#define OVERLOAD               180  /* \overload */
#define P                      181  /* \p */
#define PACKAGE                182  /* \package */
#define PAGE                   183  /* \page */
#define PAR                    184  /* \par */
#define PARAGRAPH              185  /* \paragraph */
#define PARAM                  186  /* \param */
#define POST                   187  /* \post */
#define PRE                    188  /* \pre */
#define PRIVATE                189  /* \private (PHP only) */
#define PRIVATESECTION         190  /* \privatesection (PHP only) */
#define PROPERTY               191  /* \property */
#define PROTECTED              192  /* \protected (PHP only) */
#define PROTECTEDSECTION       193  /* \protectedsection (PHP only) */
#define PROTOCOL               194  /* \protocol */
#define PUBLIC                 195  /* \public (PHP only) */
#define PUBLICSECTION          196  /* \publicsection (PHP only) */
#define REF                    197  /* \ref */
#define RELATES                198  /* \relates */
#define RELATESALSO            199  /* \relatesalso */
#define REMARKS                200  /* \remarks */
#define RETURN_COMMAND         201  /* \return */
#define RETVAL                 202  /* \retval */
#define SA                     203  /* \sa */
#define SECTION                204  /* \section */
#define SEE                    205  /* \see */
#define SHOWINITIALIZER        206  /* \showinitializer */
#define SINCE                  207  /* \since */
#define SKIP                   208  /* \skip */
#define SKIPLINE               209  /* \skipline */
#define STRUCT                 210  /* \struct */
#define SUBPAGE                211  /* \subpage */
#define SUBSECTION             212  /* \subsection */
#define SUBSUBSECTION          213  /* \subsubsection */
#define TEST                   214  /* \test */
#define THROW_COMMAND          215  /* \throw */
#define TODO_COMMAND           216  /* \todo */
#define TPARAM_COMMAND         217  /* \tparam */
#define TYPEDEF_COMMAND        218  /* \typedef */
#define UNION_COMMAND          219  /* \union */
#define UNTIL_COMMAND          220  /* \until */
#define VAR_COMMAND            221  /* \var */
#define VERBATIM               222  /* \verbatim */
#define VERBININCLUDE          223  /* \verbinclude */
#define VERSION                224  /* \version */
#define WARNING                225  /* \warning */
#define WEAKGROUP              226  /* \weakgroup */
#define XMLONLY                227  /* \xmlonly */
#define XREFITEM               228  /* \xrefitem */
#define DOLLAR_COMMAND         229  /* \$ */
#define AT_COMMAND             230  /* \@ */
#define SLASH_COMMAND          231  /* \\ */
#define AND_COMMAND            232  /* \& */
#define TILDE_COMMAND          233  /* \~ */
#define LEFTANGLEBRACKET       234  /* \< */
#define RIGHTANGLEBRACKET      235  /* \> */
#define POUND_COMMAND          236  /* \# */
#define PERCENT_COMMAND        237  /* \%  */

#endif
