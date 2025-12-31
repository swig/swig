/* -----------------------------------------------------------------------------
 * std_set.i
 *
 * SWIG typemaps for std::set<T>
 * Lua implementation
 * ----------------------------------------------------------------------------- */

%{
#include <set>
#include <stdexcept>
%}

%include <std_common.i>
%include <std_except.i>

/*
 * std::set wrapper for Lua.
 * Provides a simple interface to C++ std::set container.
 */

namespace std {

    template<class T, class C = std::less<T> >
    class set {
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

        size_type size() const;
        bool empty() const;
        void clear();

        void swap(set& other);

        size_type count(const key_type& x) const;
        size_type erase(const key_type& x);

        %extend {
            // Insert an element into the set
            // Returns true if the element was inserted, false if it already existed
            bool insert(const T& x) {
                return self->insert(x).second;
            }

            // Check if an element exists in the set
            bool contains(const T& x) {
                return self->count(x) > 0;
            }

            // Alias for contains (has_key is common in map-like containers)
            bool has_key(const T& x) {
                return self->count(x) > 0;
            }

            // Remove an element from the set
            // Returns true if the element was removed, false if it didn't exist
            bool remove(const T& x) {
                return self->erase(x) > 0;
            }

            // Add an element (alias for insert, does not return status)
            void add(const T& x) {
                self->insert(x);
            }

            // Discard an element (alias for remove, like Python's discard)
            void discard(const T& x) {
                self->erase(x);
            }

            // Get an element from the set (throws if not found)
            const T& get(const T& x) throw (std::out_of_range) {
                typename std::set<T, C>::iterator i = self->find(x);
                if (i != self->end())
                    return *i;
                else
                    throw std::out_of_range("element not found in set");
            }

            // __getitem__ for Lua - allows checking if element exists (returns the element if found)
            const T& __getitem__(const T& x) throw (std::out_of_range) {
                typename std::set<T, C>::iterator i = self->find(x);
                if (i != self->end())
                    return *i;
                else
                    throw std::out_of_range("element not found in set");
            }

            // Convert set to a Lua table (returns as a list of elements)
            // This can be used with pairs() in Lua
            std::vector<T> to_table() {
                return std::vector<T>(self->begin(), self->end());
            }

            // Get element at index (for iteration purposes)
            // Note: This is O(n) operation, use sparingly
            const T& __getitem_by_index__(unsigned int idx) throw (std::out_of_range) {
                if (idx >= self->size())
                    throw std::out_of_range("set index out of range");
                typename std::set<T, C>::iterator it = self->begin();
                std::advance(it, idx);
                return *it;
            }
        }
    };
}

/* 
 * Include std_vector.i for the to_table() method return type
 * if you want to use to_table(), you should also include std_vector.i
 * and create the appropriate template instantiation
 */
