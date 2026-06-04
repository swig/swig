
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

%constant int BRISTOLS=800;

%kotlinconstvalue(100L) APPLES;
%inline %{
#define APPLES 100LL
%}

%kotlinconst(0);
%constant long long ROSY=900LL;
