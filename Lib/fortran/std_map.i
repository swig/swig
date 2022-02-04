/* -------------------------------------------------------------------------
 * std_map.i
 * ------------------------------------------------------------------------- */

%include "std_common.i"

%{
#include <map>
%}

%define %swig_std_map(_Key, _Value, _Compare)

public:
  typedef size_t size_type;
  typedef ptrdiff_t difference_type;
  typedef _Key key_type;
  typedef _Value mapped_type;
  typedef std::pair<const _Key, _Value> value_type;
  typedef value_type *pointer;
  typedef const value_type *const_pointer;
  typedef value_type &reference;
  typedef const value_type &const_reference;

  map();

  // - Use native Fortran integers in proxy code
  %apply int FORTRAN_INT {size_type};

  bool empty() const;
  size_type size() const;
  void clear();

  %fortransubroutine erase;

  size_type erase(const key_type &x);
  size_type count(const key_type &x) const;

  %fortransubroutine insert;

  %extend {
    bool insert(const _Key& k, const _Value& v) {
      std::pair<std::map<_Key, _Value, _Compare >::iterator, bool> result = $self->insert(std::pair<_Key, _Value>(k, v));
      return result.second;
    }

    const _Value& get(const _Key& k) {
      return (*$self)[k];
    }
    void set(const _Key& k, const _Value& v) {
      (*$self)[k] = v;
    }
  }

%enddef

namespace std {
template<class _Key, class _Value, class _Compare = std::less<_Key > >
class map {
  %swig_std_map(_Key, _Value, _Compare);
};
} // namespace std
