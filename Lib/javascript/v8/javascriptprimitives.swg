%typemap(in) bool
%{ $1 = ($1_ltype) $input->BooleanValue();%} 

// Primitive types
%typemap(in) char, 
             signed char, 
             unsigned char, 
             short, 
             unsigned short, 
             int
%{ $1 = ($1_ltype) $input->Int32Value();%}	

%typemap(in) unsigned int, 
             long, 
             unsigned long, 
             long long, 
             unsigned long long
%{ $1 = ($1_ltype) $input->UInt32Value();%}

%typemap(in) float, double
%{ $1 = ($1_ltype) $input->NumberValue();%}


%typemap(in) const bool &,  bool &,
             const char &,  char &,
             const signed char &, signed char &,
             const unsigned char &, unsigned char &,
             const short &, short &,
             const unsigned short &, unsigned short &,
             const int &, int &,
             const unsigned int &, unsigned int &,
             const long &,  long &,
             const unsigned long &, unsigned long &,
             const long long &, long long &,
             const unsigned long long &, unsigned long long &,
             const float &, float &,
             const double &, double &
%{ 
  // TODO: typemap(in) const bool& at al
}

%typemap(out) bool
%{ $result = v8::Boolean::New($1);%} 

%typemap(out) char, 
             signed char, 
             unsigned char,
             short, 
             unsigned short, 
             int
%{ $result = v8::Int32::New($1);%}
             
%typemap(out) unsigned int, 
             long, 
             unsigned long, 
             long long,
             unsigned long long
%{ $result = v8::UInt32::New($1);%}

%typemap(out) float, double
%{ $result = v8::Number::New($1); %}

%typemap(out) const bool &, bool &
%{ $result = v8::Boolean::New((*$1);%}

%typemap(out) const char &, char &,
              const signed char &, signed char &,
              const unsigned char &, unsigned char &,
              const short &, short &,
              const unsigned short &, unsigned short &,
              const int &, int &
%{ $result = v8::Int32::New((*$1);%}
              
%typemap(out) const unsigned int &, unsigned int &,
            const long &, long &,
            const unsigned long &, unsigned long &,
            const long long &, long long &,
            const unsigned long long &, unsigned long long &
%{ $result = v8::UInt32::New(*$1);%}

%typemap(out) const float &, float &,
            const double &, double &
%{ $result = v8::Number::New(*$1);%}

%typemap(in) short *, 
             unsigned short *, 
             int *, 
             unsigned int *, 
             long *, 
             unsigned long *, 
             long long *, 
             unsigned long long *,
             float *, 
             double *
%{
    // TODO: typemap(in): short* et al.
%}


%typemap(out) short *, 
             unsigned short *, 
             int *, 
             unsigned int *, 
             long *, 
             unsigned long *, 
             long long *, 
             unsigned long long *,
             float *, 
             double *
%{
    // TODO: typemap(out) short* et al.
%}

%typemap(out) void
%{ $result = v8::Undefined(); %}


%typemap(in) char *
%{
    v8::String::Utf8Value _$1($input);
    $1 = *_$1;
%}

%typemap(out) char *
%{
    // TODO: output typemap for char*
%}

%typemap(in) char *& ($*1_ltype temp = 0) %{ 
    // TODO: input typemap for char*&
%}

%typemap(out) char *& 
%{ 
    // TODO: output typemap for char*&
%}

/* char arrays - treat as String */
%typemap(in) char[ANY], char[] %{
    // TODO: input typemap for char[]
%}

%typemap(out) char[ANY], char[] 
%{
    // TODO: output typemap for char[]
%}

%typemap(freearg) char *, char *&, char[ANY], char[] //TODO: Not working: A memory leak
%{ 
    // TODO: freearg char* et al
%}

/* Typemaps for composite types */
%typemap(in) SWIGTYPE ($&1_type argp)	// Objects passed by value, convert to a pointer
%{ 
    // TODO: input typemap for composite types
%}

%typemap(out) SWIGTYPE ($&1_type temp)
%{
    // TODO: output typemap for composite types
%}

%typemap(in) SWIGTYPE *, SWIGTYPE &
%{
    // TODO: input typemap for ptr types
%}

%typemap(out) SWIGTYPE *, SWIGTYPE & 
%{
    // TODO: output typemap for ptr types
%}

// TODO: sanity check?
%typemap(arginit) SWIGTYPE * 
%{%}

%typemap(in) SWIGTYPE (CLASS::*) "" 

%typemap(out) SWIGTYPE (CLASS::*) 
%{
    // TODO: output typemap for CLASS::*
%}

// Default array handling
%typemap(in) SWIGTYPE [] %{ 
    // TODO: typemap for arrays; 
%}

%typemap(out) SWIGTYPE [] %{ $result = $1; %} 

// Some ANSI C typemaps */
%apply unsigned long { size_t };

%apply const unsigned long & { const size_t & };

// Array reference typemaps
%apply SWIGTYPE & { SWIGTYPE ((&)[ANY]) }

// const pointers
%apply SWIGTYPE * { SWIGTYPE *const }
