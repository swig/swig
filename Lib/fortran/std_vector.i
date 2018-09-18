/* -------------------------------------------------------------------------
 * std_vector.i
 * ------------------------------------------------------------------------- */

%{
#include <vector>
%}

/*!
 * This module defines a std::vector class and conversion typemaps.
 *
 * Like the `std/std_vector.i` header, we convert based on the type. Use the %apply directive (with particular argument and/or function names) to change
 * the behavior.
 *
 * - f(std::vector<T>), f(const std::vector<T>&):
 *   the parameter is read-only, so we treat natively.
 * - f(std::vector<T>&), f(std::vector<T>*):
 *   the parameter may be modified: only a wrapped std::vector can be passed.
 * - std::vector<T> f(), const std::vector<T>& f():
 *   the vector is returned by copy; treat natively.
 * - std::vector<T>& f(), std::vector<T>* f():
 *   the vector is returned by reference; return a wrapped reference.
 * - const std::vector<T>* f(), f(const std::vector<T>*):
 *   for consistency, they expect and return a plain vector pointer.
 *
 * To avoid wrapping the std::vector class but still use the typemaps,
 * `%template() std::vector<double>` .
 */
%include "std_container.i"
%include "typemaps.i"

namespace std {
  template<class _Tp, class _Alloc = std::allocator<_Tp> >
  class vector {
  public:
    typedef std::size_t size_type;
    typedef _Tp value_type;
    typedef value_type *pointer;
    typedef const value_type *const_pointer;
    typedef _Tp &reference;
    typedef const _Tp &const_reference;
    typedef _Alloc allocator_type;

  public:
    // Constructors
    vector();
    vector(size_type count);
    vector(size_type count, const value_type &v);

    // Accessors
    size_type size() const;
    size_type capacity() const;
    bool empty() const;
    void clear();

    // Modify
    void reserve(size_type count);
    void resize(size_type count);
    void resize(size_type count, const value_type &v);
    void push_back(const value_type &v);

    const_reference front() const;
    const_reference back() const;

    // Instantiate typemaps for this particular vector
    %std_native_container(std::vector<_Tp, _Alloc >)

    // Enable view output and input
    %apply vector<_Tp, _Alloc >& POINTER { vector<_Tp, _Alloc >& view() };
    %apply (const SWIGTYPE *DATA, ::size_t SIZE)
    { (const value_type* DATA, size_type SIZE) };

    // Extend for Fortran
    %extend{
      // C indexing used here!
      void set(size_type index, const_reference v) {
        // TODO: check range
        (*$self)[index] = v;
      }

      // C indexing used here!
      value_type get(size_type index) {
        // TODO: check range
        return (*$self)[index];
      }

      // Assign from another vector
      void assign(const value_type* DATA, size_type SIZE) {
        $self->assign(DATA, DATA + SIZE);
      }

      // Get a mutable view to ourself
      vector<_Tp, _Alloc >& view() {
        return *$self;
      }
  }
};

// Specialize on bool
template<class _Alloc >
class vector<bool, _Alloc > {
  /* NOT IMPLEMENTED */
};
} // end namespace std
