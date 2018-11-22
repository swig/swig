/* -----------------------------------------------------------------------------
 * std_unordered_set.i
 *
 * SWIG typemaps for std::unordered_set
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

// ------------------------------------------------------------------------
// std::unordered_set
// ------------------------------------------------------------------------

%{
#include <unordered_set>
%}

namespace std {

template <class KeyType>
class unordered_set {
  public:
    unordered_set();
    unordered_set(const unordered_set<KeyType>&);

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