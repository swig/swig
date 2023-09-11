%module preproc_cpp


// booleans start
#if false
# error "boolean preproc check fail false"
#else
#endif

#if !false
#else
# error "boolean preproc check fail !false"
#endif

#if true
#else
# error "boolean preproc check fail true"
#endif

#if !true
# error "boolean preproc check fail !true"
#else
#endif

#if (true)
#else
# error "boolean preproc check fail (true)"
#endif

#if (0 || true)
#else
# error "boolean preproc check fail (0 || true)"
#endif
// booleans end


// Comma in macro - https://github.com/swig/swig/issues/974 (for /* */)
// and https://github.com/swig/swig/pull/1166 (for //)
// Also see preproc.i
%inline %{
#define swig__attribute__(x)
#define TCX_PACKED(d) d swig__attribute__ ((__packed__))


TCX_PACKED (typedef struct tcxMessageTestImpl
{
    int mHeader; /**< comment */
}) tcxMessageTest;


TCX_PACKED (typedef struct tcxMessageBugImpl
{
    int mBid; /**< Bid price and size, check PresentMap if available in message */
}) tcxMessageBug;


TCX_PACKED (typedef struct tcxMessageTestImpl2
{
    int mHeader; ///< comment
}) tcxMessageTest2;


TCX_PACKED (typedef struct tcxMessageBugImpl2
{
    int mBid; ///< Bid price and size, check PresentMap if available in message
}) tcxMessageBug2;


%}
