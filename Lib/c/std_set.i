/* -----------------------------------------------------------------------------
 * std_set.i
 *
 * SWIG typesets for std::set
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

// ------------------------------------------------------------------------
// std::set
// ------------------------------------------------------------------------

%{
#include <set>
#include <stdexcept>
%}

namespace std {
  template<class T> class set {
    public:
      typedef size_t size_type;
      typedef ptrdiff_t difference_type;
      typedef T key_type;
      typedef T value_type;
      typedef value_type* pointer;
      typedef const value_type* const_pointer;
      typedef value_type& reference;
      typedef const value_type& const_reference;

      set();
      set(const set& other);

      size_t size() const;
      bool empty() const;
      void clear();
      %extend {
        bool add(const T& item) {
          return self->insert(item).second;
        }
        bool del(const T& item) {
          return self->erase(item) != 0;
        }
        bool has(const T& item) const {
          return self->count(item) != 0;
        }
      }
  };
}
