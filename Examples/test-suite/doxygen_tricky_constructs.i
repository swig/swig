# This file contains tests for situations, which do not normally
# appear in the code, but must neverthless be handled correctly.

%module doxygen_tricky_constructs

%inline %{

    # Bug 1: Tag '@endink' is not recognized becuse it is not
    # followed by whitespace.

    /** 
     * Tag endlink must be recognized also when followed by nonspace charater.
     *
     * @link Connection::getId() @endlink<br>
     */
    char g_counter;


    /** 
     * Tag endlink must be recognized also when it is the last token
     * in the commment.
     *
     * @link Connection::getId() @endlink<br>
     * @link debugIdeTraceProfilerCoverageSample.py Python example. @endlink
     */
    int g_zipCode;


    # Bug 2: Paramter 'isReportSize' is missing in comment of the overload, which
    # has it. This bug disappears if @endlink is follwed by a space.
    #
    # Bug 3: Empty line before the link is missing,
    # making the link text part of parameter description. This bug appears also
    # when there is ordinary text in place of the link in case of overload
    # with only 2 parameters.
    /**
     * Returns address of file line.
     *
     * @param fileName name of the file, where the source line is located
     * @param line line number
     * @param isGetSize if set, for every object location both address and size are returned
     *
     * @link Connection::getId() @endlink <br>
     */
    std::vector<DWORD> getAddress(const std::string &fileName, 
                                  int line, 
                                  bool isGetSize = false);

    # Bug 4: The first comment is attached to the second in Python (wrong),
    # but not in Java (correct).
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
     * @link advancedWinIDEALaunching.py Python example. @endlink <br>
     */
    class CConnectionConfig
    {
    };

    # Bug 5: Text after '\c' has no space following in Python.
    # There are also to many empty lines in multiline comments in Python.
    # Whitespaces are really a problem in Python (space and newlines),
    # I like a parameter type added to each parameter description!
    #    """
    #    Determines how long the isystem.connectshould wait for running 
    #
    #    instances to respond. Only one of lfWaitXXXflags from IConnect::ELaunchFlags 
    #
    #    may be specified. 
    #
    #    """

    /**
     * Determines how long the \c isystem.connect should wait for running 
     * instances to respond. Only one of \c lfWaitXXX flags from IConnect::ELaunchFlags
     * may be specified.
     */
    int waitTime(long waitTime);


    # Bug 6: Text after tag \ingroup appears in Python comment (empty line in
    # Java, which is acceptable):
    /** \ingroup icFacade
     *
     * This class manages connection.
     */
    int getConnection();
    
    
%}
