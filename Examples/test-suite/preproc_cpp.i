%module preproc_cpp


// Test boolean literals (https://github.com/swig/swig/pull/2394):
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


// Test alternative operator names (https://github.com/swig/swig/issues/2914):
#if true or 0
#else
# error "boolean preproc check fail true or 0"
#endif

#if true and 1
#else
# error "boolean preproc check fail true and 1"
#endif

#if true xor false
#else
# error "boolean preproc check fail true xor false"
#endif

#if 1 bitor 2
#else
# error "boolean preproc check fail 1 bitor 2"
#endif

#if not(1 bitand 2)
#else
# error "boolean preproc check fail not(1 bitand 2)"
#endif

#if compl 0
#else
# error "boolean preproc check fail compl 0"
#endif

#if (1 bitor 2) not_eq 1
#else
# error "boolean preproc check fail (1 bitor 2) not_eq 1"
#endif


// Regression tests for bugs handling a comma in a comment in a macro:
// - https://github.com/swig/swig/issues/974 (for /* */)
// - https://github.com/swig/swig/pull/1166 (for //)
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
