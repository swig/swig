
// Support for non ISO (Windows) integral types
%apply unsigned char { unsigned __int8 };
%apply const unsigned char& { const unsigned __int8& };

%apply signed char { __int8 };
%apply const signed char& { const __int8& };

%apply unsigned short { unsigned __int16 };
%apply const unsigned short& { const unsigned __int16& };

%apply short { __int16 };
%apply const short& { const __int16& };

%apply unsigned int { unsigned __int32 };
%apply const unsigned int& { const unsigned __int32& };

%apply int { __int32 };
%apply const int& { const __int32& };

%apply unsigned long long { unsigned __int64 };
%apply const unsigned long long& { const unsigned __int64& };

%apply long long { __int64 };
%apply const long long& { const __int64& };

