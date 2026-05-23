/* -----------------------------------------------------------------------------
 * std_unordered_set.i
 *
 * SWIG typemaps for std::unordered_set<T>
 * Lua implementation
 * ----------------------------------------------------------------------------- */

%{
#include <unordered_set>
#include <stdexcept>
%}

%include <std_common.i>
%include <std_except.i>

/*
 * std::unordered_set wrapper for Lua.
 * Provides a simple interface to C++ std::unordered_set container.
 */

namespace std {

    template<class T, class H = std::hash<T> >
    class unordered_set {
    public:
        typedef size_t size_type;
        typedef ptrdiff_t difference_type;
        typedef T key_type;
        typedef T value_type;
        typedef value_type* pointer;
        typedef const value_type* const_pointer;
        typedef value_type& reference;
        typedef const value_type& const_reference;

        unordered_set();
        unordered_set(const unordered_set& other);

        size_type size() const;
        bool empty() const;
        void clear();

        void swap(unordered_set& other);

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
                typename std::unordered_set<T, H>::iterator i = self->find(x);
                if (i != self->end())
                    return *i;
                else
                    throw std::out_of_range("element not found in set");
            }

            // __getitem__ for Lua - allows checking if element exists (returns the element if found)
            const T& __getitem__(const T& x) throw (std::out_of_range) {
                typename std::unordered_set<T, H>::iterator i = self->find(x);
                if (i != self->end())
                    return *i;
                else
                    throw std::out_of_range("element not found in set");
            }
        }
    };
}
