
/* ------------------------------------------------------------
 * --- ANSI/Posix C/C++ types ---
 * ------------------------------------------------------------ */

%apply unsigned long { size_t };
%apply const unsigned long& { const size_t& };
%apply unsigned long& { size_t& };

%apply long { ptrdiff_t };
%apply const long& { const ptrdiff_t& };
%apply long& { ptrdiff_t& };

#ifdef __cplusplus
%apply unsigned long { std::size_t };
%apply const unsigned long& { const std::size_t& };
%apply unsigned long& { std::size_t& };

%apply long { std::ptrdiff_t };
%apply const long& { const std::ptrdiff_t& };
%apply long& { std::ptrdiff_t& };
#endif



