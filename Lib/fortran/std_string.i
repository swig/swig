/* -------------------------------------------------------------------------
 * std_string.i
 * ------------------------------------------------------------------------- */

%include <forstring.swg>

/* -------------------------------------------------------------------------
 * DEFINITIONS
 * ------------------------------------------------------------------------- */
namespace std {
class string {
public:
  typedef std::size_t size_type;
  typedef char value_type;
  //typedef const char& const_reference;
  typedef const char *const_pointer;
  typedef char *pointer;

public:
  // >>> Construct and assign

  string();
  void resize(size_type count);
  void clear();

  // >>> ACCESS

  size_type size() const;
  size_type length() const;

  %extend {
    %apply const std::string &NATIVE{ const std::string & str };
    // Access as a newly allocated fortran string
    const std::string &str() { return *$self; }
  }
};
}


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
