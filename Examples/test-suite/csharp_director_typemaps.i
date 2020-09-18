%module (directors="1") csharp_director_typemaps

// This tests that the csout typemap is handled correctly in the director code.
// The 'out' needs stripping in some parts of the generated director code.

%feature("director") InStream;

%apply void *VOID_INT_PTR { void * }

%typemap(ctype)         int* readLen, int* writeLen "/*ctype*/ int*"
%typemap(imtype)        int* readLen, int* writeLen "/*imtype*/ out int"
%typemap(cstype)        int* readLen                "/*cstype*/ out int"
// Note for below: 'out' used in typemap comment
%typemap(cstype)                      int* writeLen "/*out cstype out*/ out int"
%typemap(csin)          int* readLen, int* writeLen "/*csin*/ out $csinput"
%typemap(in)            int* readLen, int* writeLen %{/*in*/  $1 = ($1_ltype)$input; %}
%typemap(out)           int* readLen, int* writeLen %{/*out*/ $result = (void *)$1; %}
%typemap(csdirectorin)  int* readLen, int* writeLen "/*csdirectorin*/ out $iminput"
%typemap(csdirectorout) int* readLen, int* writeLen "/*csdirectorout*/ $cscall"
%typemap(directorin)    int* readLen, int* writeLen "/*directorin*/ $input = $1;"
%typemap(directorout)   int* readLen, int* writeLen %{/*directorout*/  $result = ($1_ltype)$input; %}

%inline %{
class InStream
{
public:
    virtual int Read(void* buf, int len, int* readLen) = 0;
    virtual int Write(void* buf, int len, int* writeLen) = 0;
    virtual ~InStream() {}
};
int callRead(InStream* stream, void* buf, int len, int* readLen) {
  return stream->Read(buf, len, readLen);
}
int callWrite(InStream* stream, void* buf, int len, int* writeLen) {
  return stream->Write(buf, len, writeLen);
}
%}
