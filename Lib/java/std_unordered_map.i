/* -----------------------------------------------------------------------------
 * std_unordered_map.i
 *
 * SWIG typemaps for std::unordered_map
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

// ------------------------------------------------------------------------
// std::unordered_map
// ------------------------------------------------------------------------

%{
#include <unordered_map>
#include <stdexcept>
%}

namespace std {

template<class KeyType, class MappedType> class unordered_map {
  public:
    typedef size_t size_type;
    typedef ptrdiff_t difference_type;
    typedef KeyType key_type;
    typedef MappedType mapped_type;
    unordered_map();
    unordered_map(const unordered_map<KeyType, MappedType>&);

    unsigned int size() const;
    bool empty() const;
    void clear();

    %extend {
      const MappedType& get(const KeyType& key) throw (std::out_of_range) {
        std::unordered_map<KeyType, MappedType>::iterator i = self->find(key);

        if (i != self->end()) {
          return i->second;
        } else {
          throw std::out_of_range("key not found");
        }
      }

      void set(const KeyType& key, const MappedType& x) {
        (*self)[key] = x;
      }

      void del(const KeyType& key) throw (std::out_of_range) {
        std::unordered_map<KeyType, MappedType>::iterator i = self->find(key);

        if (i != self->end()) {
          self->erase(i);
        } else {
          throw std::out_of_range("key not found");
        }
      }

      bool has_key(const KeyType& key) {
        std::unordered_map<KeyType, MappedType>::iterator i = self->find(key);
        return i != self->end();
      }
    }
};

}  // namespace std
