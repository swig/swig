/* -----------------------------------------------------------------------------
 * std_unordered_map.i
 *
 * SWIG typemaps for std::unordered_map
 * Lua implementation
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

// ------------------------------------------------------------------------
// std::unordered_map
// ------------------------------------------------------------------------

%{
#include <unordered_map>
#include <algorithm>
#include <stdexcept>
%}

// exported class

namespace std {

    template<class K, class T, class H = std::hash<K> > class unordered_map {
        // add typemaps here
      public:
        typedef size_t size_type;
        typedef ptrdiff_t difference_type;
        typedef K key_type;
        typedef T mapped_type;
        typedef std::pair< const K, T > value_type;
        typedef value_type* pointer;
        typedef const value_type* const_pointer;
        typedef value_type& reference;
        typedef const value_type& const_reference;

        unordered_map();
        unordered_map(const unordered_map& other);
        
        unsigned int size() const;
        bool empty() const;
        void clear();
        %extend {
            const T& get(const K& key) throw (std::out_of_range) {
                std::unordered_map< K, T, H >::iterator i = self->find(key);
                if (i != self->end())
                    return i->second;
                else
                    throw std::out_of_range("key not found");
            }
            void set(const K& key, const T& x) {
                (*self)[key] = x;
            }
            void del(const K& key) throw (std::out_of_range) {
                std::unordered_map< K, T, H >::iterator i = self->find(key);
                if (i != self->end())
                    self->erase(i);
                else
                    throw std::out_of_range("key not found");
            }
            bool has_key(const K& key) {
                std::unordered_map< K, T, H >::iterator i = self->find(key);
                return i != self->end();
            }
            // Alias for has_key, more natural for Lua
            bool contains(const K& key) {
                std::unordered_map< K, T, H >::iterator i = self->find(key);
                return i != self->end();
            }
            // __getitem__ for Lua - allows map[key] syntax
            const T& __getitem__(const K& key) throw (std::out_of_range) {
                std::unordered_map< K, T, H >::iterator i = self->find(key);
                if (i != self->end())
                    return i->second;
                else
                    throw std::out_of_range("key not found");
            }
            // __setitem__ for Lua - allows map[key] = value syntax
            void __setitem__(const K& key, const T& x) {
                (*self)[key] = x;
            }
            // Remove element by key, returns true if element was removed
            bool remove(const K& key) {
                std::unordered_map< K, T, H >::iterator i = self->find(key);
                if (i != self->end()) {
                    self->erase(i);
                    return true;
                }
                return false;
            }
        }
    };
}
