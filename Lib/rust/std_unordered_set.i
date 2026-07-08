/* -----------------------------------------------------------------------------
 * std_unordered_set.i
 *
 * std::unordered_set<T, H> wrapper support for Rust.
 * ----------------------------------------------------------------------------- */

%{
#include <iterator>
#include <stdexcept>
#include <unordered_set>
%}

%include <std_except.i>

namespace std {

%define SWIG_RUST_STD_UNORDERED_SET_INTERNAL(VALUETYPE, HASHTYPE)
%typemap(rustbody) unordered_set< VALUETYPE, HASHTYPE > %{
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

%typemap(rusttraits) unordered_set< VALUETYPE, HASHTYPE > %{
impl<'a> IntoIterator for &'a $rustclassname {
  type Item = $rusttemplarg0;
  type IntoIter = Box<dyn Iterator<Item = Self::Item> + 'a>;

  fn into_iter(self) -> Self::IntoIter {
    Box::new(self.iter())
  }
}
%}
%enddef

SWIG_RUST_STD_UNORDERED_SET_INTERNAL(T, H)

template<class T, class H = std::hash<T> > class unordered_set {
public:
  typedef size_t size_type;
  typedef ptrdiff_t difference_type;
  typedef T key_type;
  typedef T value_type;
  typedef value_type *pointer;
  typedef const value_type *const_pointer;
  typedef value_type &reference;
  typedef const value_type &const_reference;

  unordered_set();
  unordered_set(const unordered_set &other);
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
      std::unordered_set<T, H>::const_iterator it = $self->begin();
      std::advance(it, index);
      return *it;
    }
  }
};

}
