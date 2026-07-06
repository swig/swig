
// This testcase uses the %kotlinconst directive to control how constants are initialised

%module kotlin_constants

%pragma(kotlin) constantsmodifiers="interface" // change to default access

%constant short DIPSTICK=100;

// Set default Kotlin const code generation
%kotlinconst(1);

// Modify the code generation to use JNI function call initialisation for some difficult cases
%kotlinconst(0) TOM;
%kotlinconst(0) ORCHESTRA_STALLS;
%kotlinconst(0) PORKY;

%inline %{
#define CHINA 2*100
#define TOM 300ULL
#define ORCHESTRA_STALLS 400LL
#define JAM_JAR "500"
#define OXO '6'
#define PORKY !7
%}

// Bitwise and shift operators have no operator form in Kotlin, so as compile-time
// constants they must be translated to the inv()/shl/shr/and/xor/or infix functions.
// The values are chosen to exercise each operator and operator precedence.
%inline %{
#define BIT_SHIFT  (1 << 0)
#define BIT_OR     (0xF0 | 0x0F)
#define BIT_COMBO  ((1 << 2) | (1 << 3))
#define BIT_AND    (0xFF & 0x0F)
#define BIT_XOR    (0xFF ^ 0x0F)
#define BIT_INV    (~0)
#define BIT_PREC   (1 << 2 + 1)
#define BIT_LONG   (1LL << 40)
%}

%constant int BRISTOLS=800;

%kotlinconstvalue(100L) APPLES;
%inline %{
#define APPLES 100LL
%}

%kotlinconst(0);
%constant long long ROSY=900LL;
