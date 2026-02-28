/* -----------------------------------------------------------------------------
 * std_array.i
 *
 * SWIG typemaps for std::array<T, N>
 * Lua implementation
 * ----------------------------------------------------------------------------- */

%{
#include <array>
#include <algorithm>
#include <stdexcept>
%}

%include <std_common.i>
%include <std_except.i>

/*
 * std::array wrapper for Lua.
 * Note: this is a simplified version that provides basic array functionality.
 * The array is a fixed-size container, so no push_back/pop_back operations.
 */

namespace std {

    template<class T, size_t N>
    class array {
    public:
        typedef size_t size_type;
        typedef ptrdiff_t difference_type;
        typedef T value_type;
        typedef value_type* pointer;
        typedef const value_type* const_pointer;
        typedef value_type& reference;
        typedef const value_type& const_reference;

        array();
        array(const array& other);

        size_type size() const;
        size_type max_size() const;
        bool empty() const;

        void fill(const value_type& value);
        void swap(array& other);

        // Front and back access (read-only for safety, like vector)
        T front() const;
        T back() const;

        %extend {
            // Lua __getitem__ metamethod (1-based indexing internally converts to 0-based)
            T __getitem__(unsigned int idx) throw (std::out_of_range) {
                if (idx >= N)
                    throw std::out_of_range("array index out of range");
                return (*self)[idx];
            }

            // Lua __setitem__ metamethod
            void __setitem__(unsigned int idx, T val) throw (std::out_of_range) {
                if (idx >= N)
                    throw std::out_of_range("array index out of range");
                (*self)[idx] = val;
            }

            // Get element at index with bounds checking
            const T& get(unsigned int idx) throw (std::out_of_range) {
                if (idx >= N)
                    throw std::out_of_range("array index out of range");
                return (*self)[idx];
            }

            // Set element at index with bounds checking
            void set(unsigned int idx, const T& val) throw (std::out_of_range) {
                if (idx >= N)
                    throw std::out_of_range("array index out of range");
                (*self)[idx] = val;
            }

            // Return pointer to first element (for at() style access)
            T at(unsigned int idx) throw (std::out_of_range) {
                if (idx >= N)
                    throw std::out_of_range("array index out of range");
                return (*self)[idx];
            }

            // Reverse the array in place
            void reverse() {
                std::reverse($self->begin(), $self->end());
            }
        }
    };
}

