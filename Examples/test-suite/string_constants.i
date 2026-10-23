%module string_constants
// Test unusual string constants

%warnfilter(SWIGWARN_TYPEMAP_CHARLEAK);

#if defined(SWIGCSHARP)
%csconst(1);
#endif
#if defined(SWIGJAVA)
%javaconst(1);
#endif
#if defined(SWIGD)
%dmanifestconst;
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
// Characters after an embedded NUL
#define EN1 "a\0bc"
// Universal character names, the same as SS1 and SS2
#define UU1 "\u00C6\u00CEOU\n"
%}
%constant SS2="ÆÎOU\n";
%constant AA2="A\rB\nC";
%constant EE2="\124\125\126";
%constant XX2="\x57\x58\x59";
%constant ZS2="\0";
%constant ES2="";
%constant QQ2="\b00! \18\14200!";
%constant PR2=("paren");
%constant EN2="a\0bc";
%constant UU2="\u00C6\u00CEOU\n";

// The wrapper is given the default value
%feature("compactdefaultargs") things::embedded_nul_default;

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
  bool embedded_nul_default(const char *s = "a\0bc") { return s[0] == 'a' && s[1] == '\0' && s[2] == 'b' && s[3] == 'c'; }
};
%}

#if defined(SWIGCSHARP) || defined(SWIGD) || defined(SWIGJAVA)
// Static member constants plus wide string and character constants, wrapped as a pointer without typemaps for wchar_t
%inline %{
#define WS1 L"\u00C6\u00CEOU\n"
#define WC1 L'\u00C6'
// An overlong UTF-8 encoding of '"', so two chars, rather than a '"' ending the string in the target language
#define OL1 "\xC0\xA2"
%}
%constant const wchar_t *WS2 = L"\u00C6\u00CEOU\n";

%extend things {
  static const char *const SS5 = "ÆÎOU\n";
  static const char *const EN5 = "a\0bc";
#if !defined(SWIGD)
  // TODO: Fix D calling an undefined accessor for an %extend static member constant that is not a manifest constant
  static const wchar_t *const WS5 = L"\u00C6\u00CEOU\n";
#endif
}
#endif

#if defined(SWIGD) || defined(SWIGJAVA)
// Wide string and character constants given a string and character type by typemaps
%inline %{
typedef wchar_t wide_char;
%}
#if defined(SWIGJAVA)
%typemap(jstype) const wide_char * "String"
%typemap(jstype) wide_char "char"
#else
%typemap(dtype) const wide_char * "wstring"
%typemap(dtype) wide_char "wchar"
#endif
%constant const wide_char *WS6 = L"\u00C6\"\U0001F600\xE9" L"7";
%constant wide_char WC6 = L'\u00C6';
#endif
