/* -----------------------------------------------------------------------------
 * swiftprimitives.swg
 *
 * Typemaps for C/C++ primitive types -> Swift primitive types.
 * ----------------------------------------------------------------------------- */

/* ctype  : C type used in the generated C wrapper function
 * imtype : Swift type that matches the C type (used in @_silgen_name declarations)
 * swifttype : Swift type used in the proxy class public API */

/* bool */
%typemap(ctype)  bool               "int"
%typemap(imtype) bool               "Int32"
%typemap(swifttype) bool            "Bool"
%typemap(in)     bool  %{$1 = $input ? true : false;%}
%typemap(out)    bool  %{$result = $1 ? 1 : 0;%}
%typemap(swiftin)    bool  "$swiftinput ? 1 : 0"
%typemap(swiftout)   bool  %{
    let jresult = $imcall
    try swigCheckException()
    return jresult != 0
%}

/* char */
%typemap(ctype)  char               "char"
%typemap(imtype) char               "CChar"
%typemap(swifttype) char            "CChar"
%typemap(in)     char  %{$1 = $input;%}
%typemap(out)    char  %{$result = $1;%}
%typemap(swiftin)    char  "$swiftinput"
%typemap(swiftout)   char  %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

/* signed char */
%typemap(ctype)  signed char               "signed char"
%typemap(imtype) signed char               "Int8"
%typemap(swifttype) signed char            "Int8"
%typemap(in)     signed char  %{$1 = $input;%}
%typemap(out)    signed char  %{$result = $1;%}
%typemap(swiftin)    signed char  "$swiftinput"
%typemap(swiftout)   signed char  %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

/* unsigned char */
%typemap(ctype)  unsigned char               "unsigned char"
%typemap(imtype) unsigned char               "UInt8"
%typemap(swifttype) unsigned char            "UInt8"
%typemap(in)     unsigned char  %{$1 = $input;%}
%typemap(out)    unsigned char  %{$result = $1;%}
%typemap(swiftin)    unsigned char  "$swiftinput"
%typemap(swiftout)   unsigned char  %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

/* short */
%typemap(ctype)  short               "short"
%typemap(imtype) short               "Int16"
%typemap(swifttype) short            "Int16"
%typemap(in)     short  %{$1 = $input;%}
%typemap(out)    short  %{$result = $1;%}
%typemap(swiftin)    short  "$swiftinput"
%typemap(swiftout)   short  %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

/* unsigned short */
%typemap(ctype)  unsigned short               "unsigned short"
%typemap(imtype) unsigned short               "UInt16"
%typemap(swifttype) unsigned short            "UInt16"
%typemap(in)     unsigned short  %{$1 = $input;%}
%typemap(out)    unsigned short  %{$result = $1;%}
%typemap(swiftin)    unsigned short  "$swiftinput"
%typemap(swiftout)   unsigned short  %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

/* int */
%typemap(ctype)  int               "int"
%typemap(imtype) int               "Int32"
%typemap(swifttype) int            "Int32"
%typemap(in)     int  %{$1 = $input;%}
%typemap(out)    int  %{$result = $1;%}
%typemap(swiftin)    int  "$swiftinput"
%typemap(swiftout)   int  %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

/* unsigned int */
%typemap(ctype)  unsigned int               "unsigned int"
%typemap(imtype) unsigned int               "UInt32"
%typemap(swifttype) unsigned int            "UInt32"
%typemap(in)     unsigned int  %{$1 = $input;%}
%typemap(out)    unsigned int  %{$result = $1;%}
%typemap(swiftin)    unsigned int  "$swiftinput"
%typemap(swiftout)   unsigned int  %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

/* long */
%typemap(ctype)  long               "long"
%typemap(imtype) long               "Int"
%typemap(swifttype) long            "Int"
%typemap(in)     long  %{$1 = $input;%}
%typemap(out)    long  %{$result = $1;%}
%typemap(swiftin)    long  "$swiftinput"
%typemap(swiftout)   long  %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

/* unsigned long */
%typemap(ctype)  unsigned long               "unsigned long"
%typemap(imtype) unsigned long               "UInt"
%typemap(swifttype) unsigned long            "UInt"
%typemap(in)     unsigned long  %{$1 = $input;%}
%typemap(out)    unsigned long  %{$result = $1;%}
%typemap(swiftin)    unsigned long  "$swiftinput"
%typemap(swiftout)   unsigned long  %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

/* long long */
%typemap(ctype)  long long               "long long"
%typemap(imtype) long long               "Int64"
%typemap(swifttype) long long            "Int64"
%typemap(in)     long long  %{$1 = $input;%}
%typemap(out)    long long  %{$result = $1;%}
%typemap(swiftin)    long long  "$swiftinput"
%typemap(swiftout)   long long  %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

/* unsigned long long */
%typemap(ctype)  unsigned long long               "unsigned long long"
%typemap(imtype) unsigned long long               "UInt64"
%typemap(swifttype) unsigned long long            "UInt64"
%typemap(in)     unsigned long long  %{$1 = $input;%}
%typemap(out)    unsigned long long  %{$result = $1;%}
%typemap(swiftin)    unsigned long long  "$swiftinput"
%typemap(swiftout)   unsigned long long  %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

/* float */
%typemap(ctype)  float               "float"
%typemap(imtype) float               "Float"
%typemap(swifttype) float            "Float"
%typemap(in)     float  %{$1 = $input;%}
%typemap(out)    float  %{$result = $1;%}
%typemap(swiftin)    float  "$swiftinput"
%typemap(swiftout)   float  %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

/* double */
%typemap(ctype)  double               "double"
%typemap(imtype) double               "Double"
%typemap(swifttype) double            "Double"
%typemap(in)     double  %{$1 = $input;%}
%typemap(out)    double  %{$result = $1;%}
%typemap(swiftin)    double  "$swiftinput"
%typemap(swiftout)   double  %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

/* size_t */
%typemap(ctype)  size_t               "size_t"
%typemap(imtype) size_t               "Int"
%typemap(swifttype) size_t            "Int"
%typemap(in)     size_t  %{$1 = (size_t)$input;%}
%typemap(out)    size_t  %{$result = (long)$1;%}
%typemap(swiftin)    size_t  "$swiftinput"
%typemap(swiftout)   size_t  %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

/* const reference versions - same as value */
%typemap(ctype)  const bool &         "int"
%typemap(imtype) const bool &         "Int32"
%typemap(swifttype) const bool &      "Bool"
%typemap(in)     const bool & (bool temp) %{temp = ($input != 0); $1 = &temp;%}
%typemap(out)    const bool &         %{$result = *$1 ? 1 : 0;%}
%typemap(swiftin)    const bool &     "$swiftinput ? 1 : 0"
%typemap(swiftout)   const bool &     %{
    let jresult = $imcall
    try swigCheckException()
    return jresult != 0
%}

%typemap(ctype)  const int &          "int"
%typemap(imtype) const int &          "Int32"
%typemap(swifttype) const int &       "Int32"
%typemap(in)     const int & (int temp) %{temp = $input; $1 = &temp;%}
%typemap(out)    const int &          %{$result = *$1;%}
%typemap(swiftin)    const int &      "$swiftinput"
%typemap(swiftout)   const int &      %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

%typemap(ctype)  const unsigned int & "unsigned int"
%typemap(imtype) const unsigned int & "UInt32"
%typemap(swifttype) const unsigned int & "UInt32"
%typemap(in)     const unsigned int & (unsigned int temp) %{temp = $input; $1 = &temp;%}
%typemap(out)    const unsigned int & %{$result = *$1;%}
%typemap(swiftin)    const unsigned int & "$swiftinput"
%typemap(swiftout)   const unsigned int & %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

%typemap(ctype)  const long &         "long"
%typemap(imtype) const long &         "Int"
%typemap(swifttype) const long &      "Int"
%typemap(in)     const long & (long temp) %{temp = $input; $1 = &temp;%}
%typemap(out)    const long &         %{$result = *$1;%}
%typemap(swiftin)    const long &     "$swiftinput"
%typemap(swiftout)   const long &     %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

%typemap(ctype)  const long long &    "long long"
%typemap(imtype) const long long &    "Int64"
%typemap(swifttype) const long long & "Int64"
%typemap(in)     const long long & (long long temp) %{temp = $input; $1 = &temp;%}
%typemap(out)    const long long &    %{$result = *$1;%}
%typemap(swiftin)    const long long & "$swiftinput"
%typemap(swiftout)   const long long & %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

%typemap(ctype)  const unsigned long long & "unsigned long long"
%typemap(imtype) const unsigned long long & "UInt64"
%typemap(swifttype) const unsigned long long & "UInt64"
%typemap(in)     const unsigned long long & (unsigned long long temp) %{temp = $input; $1 = &temp;%}
%typemap(out)    const unsigned long long & %{$result = *$1;%}
%typemap(swiftin)    const unsigned long long & "$swiftinput"
%typemap(swiftout)   const unsigned long long & %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

%typemap(ctype)  const float &        "float"
%typemap(imtype) const float &        "Float"
%typemap(swifttype) const float &     "Float"
%typemap(in)     const float & (float temp) %{temp = $input; $1 = &temp;%}
%typemap(out)    const float &        %{$result = *$1;%}
%typemap(swiftin)    const float &    "$swiftinput"
%typemap(swiftout)   const float &    %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

%typemap(ctype)  const double &       "double"
%typemap(imtype) const double &       "Double"
%typemap(swifttype) const double &    "Double"
%typemap(in)     const double & (double temp) %{temp = $input; $1 = &temp;%}
%typemap(out)    const double &       %{$result = *$1;%}
%typemap(swiftin)    const double &   "$swiftinput"
%typemap(swiftout)   const double &   %{
    let jresult = $imcall
    try swigCheckException()
    return jresult
%}

/* Director typemaps for primitives: pass-through (overrides SWIGTYPE catch-all) */
%typemap(directorin)    bool               "$input ? 1 : 0"
%typemap(directorin)    char               "$input"
%typemap(directorin)    signed char        "$input"
%typemap(directorin)    unsigned char      "$input"
%typemap(directorin)    short              "$input"
%typemap(directorin)    unsigned short     "$input"
%typemap(directorin)    int                "$input"
%typemap(directorin)    unsigned int       "$input"
%typemap(directorin)    long               "$input"
%typemap(directorin)    unsigned long      "$input"
%typemap(directorin)    long long          "$input"
%typemap(directorin)    unsigned long long "$input"
%typemap(directorin)    float              "$input"
%typemap(directorin)    double             "$input"
%typemap(directorin)    size_t             "$input"

%typemap(directorout)   bool               "($result != 0)"
%typemap(directorout)   char               "$result"
%typemap(directorout)   signed char        "$result"
%typemap(directorout)   unsigned char      "$result"
%typemap(directorout)   short              "$result"
%typemap(directorout)   unsigned short     "$result"
%typemap(directorout)   int                "$result"
%typemap(directorout)   unsigned int       "$result"
%typemap(directorout)   long               "$result"
%typemap(directorout)   unsigned long      "$result"
%typemap(directorout)   long long          "$result"
%typemap(directorout)   unsigned long long "$result"
%typemap(directorout)   float              "$result"
%typemap(directorout)   double             "$result"
%typemap(directorout)   size_t             "$result"

/* swiftdirectorin: C dispatch param -> Swift value (identity for primitives) */
%typemap(swiftdirectorin)    bool               "$input != 0"
%typemap(swiftdirectorin)    char               "$input"
%typemap(swiftdirectorin)    signed char        "$input"
%typemap(swiftdirectorin)    unsigned char      "$input"
%typemap(swiftdirectorin)    short              "$input"
%typemap(swiftdirectorin)    unsigned short     "$input"
%typemap(swiftdirectorin)    int                "$input"
%typemap(swiftdirectorin)    unsigned int       "$input"
%typemap(swiftdirectorin)    long               "$input"
%typemap(swiftdirectorin)    unsigned long      "$input"
%typemap(swiftdirectorin)    long long          "$input"
%typemap(swiftdirectorin)    unsigned long long "$input"
%typemap(swiftdirectorin)    float              "$input"
%typemap(swiftdirectorin)    double             "$input"
%typemap(swiftdirectorin)    size_t             "$input"

/* swiftdirectorout: Swift return -> C return (identity for primitives) */
%typemap(swiftdirectorout)   bool               "$input ? 1 : 0"
%typemap(swiftdirectorout)   char               "$input"
%typemap(swiftdirectorout)   signed char        "$input"
%typemap(swiftdirectorout)   unsigned char      "$input"
%typemap(swiftdirectorout)   short              "$input"
%typemap(swiftdirectorout)   unsigned short     "$input"
%typemap(swiftdirectorout)   int                "$input"
%typemap(swiftdirectorout)   unsigned int       "$input"
%typemap(swiftdirectorout)   long               "$input"
%typemap(swiftdirectorout)   unsigned long      "$input"
%typemap(swiftdirectorout)   long long          "$input"
%typemap(swiftdirectorout)   unsigned long long "$input"
%typemap(swiftdirectorout)   float              "$input"
%typemap(swiftdirectorout)   double             "$input"
%typemap(swiftdirectorout)   size_t             "$input"

/* char* / const char* director pass-through */
%typemap(directorin)    char *              "$input"
%typemap(directorin)    const char *        "$input"
%typemap(directorout)   char *              "$result"
%typemap(directorout)   const char *        "$result"
%typemap(swiftdirectorin)  char *           "$input.map { String(cString: $0) } ?? \"\""
%typemap(swiftdirectorin)  const char *     "$input.map { String(cString: $0) } ?? \"\""
