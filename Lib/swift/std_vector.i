/* -----------------------------------------------------------------------------
 * std_vector.i
 *
 * Swift typemaps for std::vector<T>.
 * Wraps the vector as a Swift proxy class with size()/get()/set()/push_back().
 * ----------------------------------------------------------------------------- */

%{
#include <vector>
#include <stdexcept>
%}

/* The vector itself is a SWIG-wrapped class; the typemaps below cover
 * passing vectors by pointer/reference as C++ class handles.
 * %template(Bytes) std::vector<uint8_t> creates a "Bytes" Swift class.
 */

namespace std {
  template<class T> class vector {
  public:
    typedef size_t size_type;
    typedef T value_type;
    typedef const value_type& const_reference;

    vector();
    vector(size_type n);
    ~vector();

    size_type size() const;
    bool empty() const;
    void clear();
    void push_back(const value_type& x);

    %extend {
      const value_type& get(int i) {
        if (i < 0 || (size_t)i >= $self->size())
          throw std::out_of_range("vector index out of range");
        return (*$self)[i];
      }
      void set(int i, const value_type& val) {
        if (i < 0 || (size_t)i >= $self->size())
          throw std::out_of_range("vector index out of range");
        (*$self)[i] = val;
      }
      /* Raw data pointer for direct buffer access from Swift */
      const value_type* data() {
        return $self->data();
      }
#ifdef SWIGSWIFT
      /* Returns element by value so Swift sees the primitive/object type,
       * not a const-ref SWIGTYPE wrapper. The swift module (swift.cxx) keys on
       * this method: every class that defines getElement(i:) automatically gets
       * a RandomAccessCollection conformance whose subscript returns exactly this
       * method's Swift type. */
      value_type getElement(int i) {
        if (i < 0 || (size_t)i >= $self->size())
          throw std::out_of_range("vector index out of range");
        return (*$self)[i];
      }
#endif
    }
  };
}

/* RandomAccessCollection conformance for std::vector wrappers is emitted
 * automatically by the swift module (Source/Modules/swift.cxx).  Every
 * %template(Name) std::vector<T> yields a Swift `Name` proxy that conforms to
 * RandomAccessCollection, with a subscript whose element type is exactly what
 * getElement(i:) returns.  No per-instantiation macro call is needed, and the
 * element type can never drift from getElement's type. */
