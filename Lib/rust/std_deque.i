/* -----------------------------------------------------------------------------
 * std_deque.i
 *
 * std::deque<T> wrapper support for Rust.
 * ----------------------------------------------------------------------------- */

%{
#include <deque>
#include <stdexcept>
%}

%include <std_except.i>

namespace std {

%define SWIG_RUST_STD_DEQUE_INTERNAL(CTYPE...)
%typemap(rustbody) deque< CTYPE > %{
  pub fn len(&self) -> usize {
    self.size() as usize
  }

  pub fn is_empty(&self) -> bool {
    self.empty()
  }

  pub fn indices(&self) -> std::ops::Range<usize> {
    0..self.len()
  }

  pub fn iter(&self) -> impl Iterator<Item = $rusttemplarg0> + '_ {
    self.indices().map(move |index| self.getitemcopy(index as i32))
  }
%}

%typemap(rusttraits) deque< CTYPE > %{
impl<'a> IntoIterator for &'a $rustclassname {
  type Item = $rusttemplarg0;
  type IntoIter = Box<dyn Iterator<Item = Self::Item> + 'a>;

  fn into_iter(self) -> Self::IntoIter {
    Box::new(self.iter())
  }
}
%}
%enddef

SWIG_RUST_STD_DEQUE_INTERNAL(T)

template<class T> class deque {
public:
  typedef size_t size_type;
  typedef ptrdiff_t difference_type;
  typedef T value_type;
  typedef value_type *pointer;
  typedef const value_type *const_pointer;
  typedef value_type &reference;
  typedef const value_type &const_reference;

  deque();
  deque(const deque &other);

  void clear();
  void push_back(const T &x);
  void push_front(const T &x);
  void pop_back();
  void pop_front();
  size_type size() const;
  bool empty() const;

  %extend {
    T getitemcopy(int index) SWIG_RUST_THROW_OUT_OF_RANGE {
      if (index >= 0 && index < (int)$self->size())
        return (*$self)[index];
      throw std::out_of_range("index");
    }

    void setitem(int index, const T &value) SWIG_RUST_THROW_OUT_OF_RANGE {
      if (index >= 0 && index < (int)$self->size()) {
        (*$self)[index] = value;
        return;
      }
      throw std::out_of_range("index");
    }
  }
};

}
