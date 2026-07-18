/* -----------------------------------------------------------------------------
 * std_set.i
 *
 * std::set<T> wrapper support for Rust.
 * ----------------------------------------------------------------------------- */

%{
#include <iterator>
#include <set>
#include <stdexcept>
%}

%include <std_except.i>

namespace std {

%define SWIG_RUST_STD_SET_INTERNAL(VALUETYPE)
%typemap(rustbody) set< VALUETYPE > %{
  pub fn len(&self) -> usize {
    self.size() as usize
  }

  pub fn is_empty(&self) -> bool {
    self.empty()
  }

  pub fn contains(&self, value: $rusttemplargin0) -> bool {
    self.count(value) != 0
  }

  pub fn indices(&self) -> std::ops::Range<usize> {
    0..self.len()
  }

  pub fn iter(&self) -> impl Iterator<Item = $rusttemplarg0> + '_ {
    self.indices().map(move |index| self.value_at(index as i32))
  }
%}

%typemap(rusttraits) set< VALUETYPE > %{
impl<'a> IntoIterator for &'a $rustclassname {
  type Item = $rusttemplarg0;
  type IntoIter = Box<dyn Iterator<Item = Self::Item> + 'a>;

  fn into_iter(self) -> Self::IntoIter {
    Box::new(self.iter())
  }
}
%}
%enddef

SWIG_RUST_STD_SET_INTERNAL(T)

template<class T> class set {
public:
  typedef size_t size_type;
  typedef ptrdiff_t difference_type;
  typedef T key_type;
  typedef T value_type;
  typedef value_type *pointer;
  typedef const value_type *const_pointer;
  typedef value_type &reference;
  typedef const value_type &const_reference;

  set();
  set(const set &other);

  void clear();
  size_type size() const;
  bool empty() const;
  size_type count(const T &x) const;
  size_type erase(const T &x);

  %extend {
    void insert_value(const T &x) {
      $self->insert(x);
    }

    T value_at(int index) SWIG_RUST_THROW_OUT_OF_RANGE {
      if (index < 0 || index >= (int)$self->size())
        throw std::out_of_range("index");
      std::set<T>::const_iterator it = $self->begin();
      std::advance(it, index);
      return *it;
    }
  }
};

}
