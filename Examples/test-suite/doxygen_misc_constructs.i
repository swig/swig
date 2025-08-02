// This file contains tests for situations, which do not normally
// appear in the code, but must nevertheless be handled correctly.

%module doxygen_misc_constructs

%warnfilter(SWIGWARN_DOXYGEN_UNKNOWN_COMMAND) backslashB;

%inline %{

    // Tag '@endink' must be recognized even if it is not
    // followed by whitespace.

    /** Tag endlink must be recognized also when followed by nonspace character.
     *
     * @link Connection::getId() @endlink<br> */

    char g_counter;


    /**
      Tag endlink must be recognized also when it is the last token
      in the comment.

      @link Connection::getId() @endlink<br>
      @link debugIdeTraceProfilerCoverageSample.py Python example. @endlink
     */
    int g_zipCode;


    // Parameter 'isReportSize' must appear in comment of the overload, which
    // has it. Empty line before link must be preserved.
    /**
     * Returns address of file line.
     *
     * @param fileName name of the file, where the source line is located
     * @param line line number
     * @param isGetSize if set, for every object location both address and size are returned
     *
     * @link Connection::getId() @endlink<br>
     */
    void getAddress(int &fileName,
                    int line,
                    bool isGetSize = false) {}

    // The first comment must be ignored.
    /**
     * \defgroup icFacade isystem.connect Facade
     *
     * This page shows the core classes, which can be used to control
     * all aspects of winIDEA, for example: debugging, analyzers, IO module, ...
     */

    /**
     * This class contains information for connection to winIDEA. Its methods
     * return reference to self, so we can use it like this:
     * <pre>
     * CConnectionConfig config = new CConnectionConfig();
     * config.discoveryPort(5534).dllPath("C:\\myWinIDEA\\connect.dll").id("main");
     * </pre>
     *
     * All parameters are optional. Set only what is required, default values are
     * used for unspecified parameters.
     * <p>
     *
     * @link advancedWinIDEALaunching.py Python example.@endlink<br>
     */
    class CConnectionConfig
    {
    };

    // Text after '\c' must be kept unchanged in Python.
    /**
     * Determines how long the \c isystem.connect should wait for running
     * instances to respond. Only one of \c lfWaitXXX flags from IConnect::ELaunchFlags
     * may be specified.
     */
    int waitTime(long waitTime) {return 33;}


    // Line with tag \ingroup must not appear in translated comment:
    /** \ingroup icFacade
     *
     * This function returns connection id.
     */
    int getConnection() {return 3;}

    // the following must produce no comment in wrapper
    /*******************************************************************/
    char getFirstLetter() {return 'a';}


    /**
     * Class description.
     */
    class ClassWithNestedEnum {
    public:
        /**
         * ENested description.
         */
        typedef enum {ONE,  ///< desc of one
                      TWO,  ///< desc of two
                      THREE ///< desc of three
        } ENested;

        /**
         * ENestedOdd description.
         */
        typedef enum {ODD_ONE   ///< desc of odd_one
                     ,ODD_TWO   ///< desc of odd_two
                     ,ODD_THREE ///< desc of odd_three
        } ENestedOdd;

        /**
         * ENestedOddPartial1 description.
         */
        typedef enum {ODD_PARTIAL1_ONE
                     ,ODD_PARTIAL1_TWO   ///< desc of odd_partial1_two
                     ,ODD_PARTIAL1_THREE ///< desc of odd_partial1_three
        } ENestedOddPartial1;

        /**
         * ENestedOddPartial3 description.
         */
        typedef enum {ODD_PARTIAL3_ONE   ///< desc of odd_partial3_one
                     ,ODD_PARTIAL3_TWO   ///< desc of odd_partial3_two
                     ,ODD_PARTIAL3_THREE
        } ENestedOddPartial3;

        /** Description for TESTENUM. */
        enum TESTENUM
        {
          /** something for none */
          TEST_NONE = 0,
          /** something for one */
          TEST_ONE,
          /** something for two */
          TEST_TWO  /** something more for two */
        };
    };

    /// SIOBeam struct description
    struct SIOBeam {

      /** testfunction - testing extra trailing doc comment */
      void testfunction(
          /** testfunction aaa parm */
          int testf_aaa,
          /** testfunction bbb parm */
          double testf_bbb,
          /** testfunction ccc parm */
          bool testf_ccc /** testfunction more for two parm */
          ) {}

      /// Constructor for input from an existing SIO file
      explicit SIOBeam(
          const char * filename,   ///< Name of input SIO file.
          int elevationOrder=1, ///< Interpolation order (0-3) in elevation
          int bearingOrder=1   ///< Interpolation order (0-3) in bearing
          ) {}
    };

    /// @return This is a bad place for this tag, but it should be ignored.
    struct StructWithReturnComment {};

    /**
        An example of a list in a documentation comment.

            - The first item of the list.
            - The second list item, on
              several indented lines,
              showing that the indentation
              is preserved.
            - And the final list item after it.

        And this is not a list item any more.
     */
    void showList() { }

    /** Incorrectly documented members, these should be post document comments, Github issue #1636 */
    struct IncorrectlyDocumentedMembers
    {
      int aaaa; //! really for bbbb value
      int bbbb; //! not for bbbb value, is quietly ignored by Doxygen and SWIG
    };

    struct OrphanedComment
    {
      /** Doxygen quietly ignores this; SWIG < 4.3.0 gave parse error. */
    };

    #include "doxygen_misc_constructs.h"

%}
    %include "doxygen_misc_constructs.h"
