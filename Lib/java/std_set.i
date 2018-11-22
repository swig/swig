/* -----------------------------------------------------------------------------
 * std_set.i
 *
 * SWIG typemaps for std::set
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

// ------------------------------------------------------------------------
// std::set
// ------------------------------------------------------------------------

%{
#include <set>
%}

namespace std {

template <class KeyType>
class set {
  public:
    set();
    set(const set<KeyType>&);

    unsigned int size() const;
    bool empty() const;
    void clear();

    %extend {
      // Returns whether item was inserted.
      bool insert(const KeyType& key) {
        return self->insert(key).second;
      }

      // Returns whether set contains key.
      bool has(const KeyType& key) {
        return (self->count(key) > 0);
      }

      // Returns whether the item was erased.
      bool erase(const KeyType& key) {
        return (self->erase(key) > 0);
      }
    }
};

}  // namespace std