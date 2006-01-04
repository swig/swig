%include <typemaps/ptrtypes.swg>
%include <perlstrings.swg>

%{
/* include here XMLCh/XMString declaration */
%}

   
%fragment("SWIG_AsPtrXMLChPtr","header",fragment="SWIG_AsCharPtrAndSize") {
SWIGINTERN int
SWIG_AsPtrXMLChPtr(SV *obj, XMLCh **val)
{
  if (!val) {
    return SWIG_AsCharPtrAndSize(obj, 0,  0, 0);
  } else {
    size_t size;
    char *ptr = 0;
    int alloc = SWIG_OLDOBJ;
    int res = SWIG_AsCharPtrAndSize(obj, &ptr, &size, &alloc);
    if (SWIG_IsOK(res)) {
      STRLEN length = size - 1;
      if (SvUTF8(input)) {
	unsigned int charsEaten = 0;
	unsigned char* sizes = %new_array(size, unsigned char);
	*val = %new_array(size, XMLCh);
	unsigned int chars_stored = 
	  UTF8_TRANSCODER->transcodeFrom((const XMLByte*) ptr,
					 (unsigned int) length,
					 (XMLCh*) *val, 
					 (unsigned int) length,
					 charsEaten,
					 (unsigned char*)sizes
					 );
	%delete_array(sizes);
	// indicate the end of the string
	(*val)[chars_stored] = '\0';
      } else {
	*val = XMLChPtr::transcode(ptr);
      }
      if (SWIG_IsNewObj(res)) %delete_array(ptr);
      return SWIG_NEWOBJ;    
    } else {
      return res;
    }
  }
}
}

%fragment("SWIG_FromXMLChPtr","header") {
SWIGINTERNINLINE SV *
SWIG_FromXMLChPtr(XMLCh* input)
{
  SV *output = sv_newmortal();
  unsigned int charsEaten = 0;
  int length  = XMLChPtr::stringLen(input);      // string length
  XMLByte* res = new XMLByte[length * UTF8_MAXLEN];          // output string
  unsigned int total_chars =
    UTF8_TRANSCODER->transcodeTo((const XMLCh*) input, 
				 (unsigned int) length,
				 (XMLByte*) res,
				 (unsigned int) length*UTF8_MAXLEN,
				 charsEaten,
				 XMLTranscoder::UnRep_Throw
				 );
  res[total_chars] = '\0';
  sv_setpv((SV*)output, (char *)res );
  SvUTF8_on((SV*)output);
  delete[] res;
  return output;
}
}


%typemaps_asptrfrom(%checkcode(STRING),
		    SWIG_AsPtrXMLChPtr, 
		    SWIG_FromXMLChPtr, 
		    "SWIG_AsPtrXMLChPtr", 
		    "SWIG_FromXMLChPtr", 
		    XMLCh *);
