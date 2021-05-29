%include <std_except.i>

%apply unsigned long { std::size_t };
%apply const unsigned long & { const std::size_t & };

