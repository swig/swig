/* -----------------------------------------------------------------------------
 * std_wstring.i
 *
 * Minimal std::wstring wrapper declarations for Rust.
 * ----------------------------------------------------------------------------- */

%{
#include <string>
%}

namespace std {

class wstring {
public:
  typedef wchar_t value_type;
  typedef size_t size_type;

  wstring();
  wstring(const wstring &other);

  size_type size() const;
  bool empty() const;
  void clear();
};

}
