%module string_constants
// Test unusual string constants

%warnfilter(SWIGWARN_TYPEMAP_CHARLEAK);

#if defined(SWIGCSHARP)
%csconst(1);
%csconstvalue("\"AEIOU\\n\"") SS1;
%csconstvalue("\"AEIOU\\n\"") SS2;
#endif
#if defined(SWIGJAVA)
%javaconst(1);
#endif
%inline %{
#define SS1 "ÆÎOU\n"
#define AA1 "A\rB\nC"
#define EE1 "\124\125\126"
#define XX1 "\x57\x58\x59"
#define ZS1 "\0"
#define ES1 ""
#define QQ1 "\b00! \18\14200!"
#define PR1 ("paren")
%}
%constant SS2="ÆÎOU\n";
%constant AA2="A\rB\nC";
%constant EE2="\124\125\126";
%constant XX2="\x57\x58\x59";
%constant ZS2="\0";
%constant ES2="";
%constant QQ2="\b00! \18\14200!";
%constant PR2=("paren");

%inline %{
static const char *SS3 = "ÆÎOU\n";
static const char *AA3 = "A\rB\nC";
static const char *EE3 = "\124\125\126";
static const char *XX3 = "\x57\x58\x59";
static const char *ZS3 = "\0";
static const char *ES3 = "";
static const char *QQ3 = "\b00! \18\14200!";
static const char *PR3 = ("paren");
struct things {
  const char * defarguments1(const char *SS4 = "ÆÎOU\n") { return SS4; }
  const char * defarguments2(const char *AA4 = "A\rB\nC") { return AA4; }
  const char * defarguments3(const char *EE4 = "\124\125\126") { return EE4; }
  const char * defarguments4(const char *XX4 = "\x57\x58\x59") { return XX4; }
  const char * defarguments5(const char *ZS4 = "\0") { return ZS4; }
  const char * defarguments6(const char *ES4 = "") { return ES4; }
  const char * defarguments7(const char *QQ4 = "\b00! \18\14200!") { return QQ4; }
  const char * defarguments8(const char *PR4 = ("paren")) { return PR4; }
};
%}
