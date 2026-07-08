/* -----------------------------------------------------------------------------
 * std_unordered_map.i
 *
 * std::unordered_map<K, T, H> wrapper support for Rust.
 * ----------------------------------------------------------------------------- */

%{
#include <iterator>
#include <unordered_map>
#include <stdexcept>
%}

%include <std_except.i>
%include <std_pair.i>

namespace std {

%define SWIG_RUST_STD_UNORDERED_MAP_INTERNAL(KEYTYPE, VALUETYPE, HASHTYPE)
%typemap(rustbody) unordered_map< KEYTYPE, VALUETYPE, HASHTYPE > %{
  pub fn len(&self) -> usize {
    self.size() as usize
  }

  pub fn is_empty(&self) -> bool {
    self.empty()
  }

  pub fn contains_key(&self, key: $rusttemplargin0) -> bool {
    self.count(key) != 0
  }

  pub fn get(&self, key: $rusttemplargin0) -> Option<$rusttemplarg1> {
    self.try_getitem(key).ok()
  }

  pub fn indices(&self) -> std::ops::Range<usize> {
    0..self.len()
  }

  pub fn keys(&self) -> impl Iterator<Item = $rusttemplarg0> + '_ {
    self.indices().map(move |index| self.key_at(index as i32))
  }

  pub fn values(&self) -> impl Iterator<Item = $rusttemplarg1> + '_ {
    self.indices().map(move |index| self.value_at(index as i32))
  }

  pub fn iter(&self) -> impl Iterator<Item = ($rusttemplarg0, $rusttemplarg1)> + '_ {
    self.indices().map(move |index| (self.key_at(index as i32), self.value_at(index as i32)))
  }
%}

%typemap(rusttraits) unordered_map< KEYTYPE, VALUETYPE, HASHTYPE > %{
impl<'a> IntoIterator for &'a $rustclassname {
  type Item = ($rusttemplarg0, $rusttemplarg1);
  type IntoIter = Box<dyn Iterator<Item = Self::Item> + 'a>;

  fn into_iter(self) -> Self::IntoIter {
    Box::new(self.iter())
  }
}
%}
%enddef

SWIG_RUST_STD_UNORDERED_MAP_INTERNAL(K, T, H)

template<class K, class T, class H = std::hash<K> > class unordered_map {
public:
  typedef size_t size_type;
  typedef ptrdiff_t difference_type;
  typedef K key_type;
  typedef T mapped_type;
  typedef std::pair<const K, T> value_type;

  unordered_map();
  unordered_map(const unordered_map &other);
  void clear();
  size_type size() const;
  bool empty() const;
  size_type count(const K &key) const;
  size_type erase(const K &key);

  %extend {
    T getitem(const K &key) SWIG_RUST_THROW_OUT_OF_RANGE {
      std::unordered_map<K, T, H>::const_iterator it = $self->find(key);
      if (it != $self->end())
        return it->second;
      throw std::out_of_range("key");
    }

    void setitem(const K &key, const T &value) {
      (*$self)[key] = value;
    }

    K key_at(int index) SWIG_RUST_THROW_OUT_OF_RANGE {
      if (index < 0 || index >= (int)$self->size())
        throw std::out_of_range("index");
      std::unordered_map<K, T, H>::const_iterator it = $self->begin();
      std::advance(it, index);
      return it->first;
    }

    T value_at(int index) SWIG_RUST_THROW_OUT_OF_RANGE {
      if (index < 0 || index >= (int)$self->size())
        throw std::out_of_range("index");
      std::unordered_map<K, T, H>::const_iterator it = $self->begin();
      std::advance(it, index);
      return it->second;
    }
  }
};

}
