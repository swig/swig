/* File : example.h */

#include <vector>

template<typename T>
class ThinVec {
public:
  typedef int size_type;
  typedef T value_type;
  typedef T *pointer;
  typedef const T *const_pointer;
  typedef std::pair<pointer, std::size_t> view_type;
  typedef std::pair<const_pointer, std::size_t> const_view_type;

  typedef typename std::vector<T>::iterator iterator;
  typedef typename std::vector<T>::const_iterator const_iterator;

private:
  std::vector<T> d_data;

public:
  // Constructors
  ThinVec() : d_data() { /* * */
  }

  ThinVec(size_type count, value_type fillval = 0) : d_data(count, fillval) { /* * */
  }

  // Accessors
  bool empty() const { return d_data.empty(); }

  size_type size() const { return d_data.size(); }

  const value_type &get(size_type index) const { return d_data.at(index); }

  void set(size_type index, const value_type &val) { d_data.at(index) = val; }

  void resize(size_type newsize, value_type fillval = T()) { d_data.resize(newsize, fillval); }

  void assign(const_view_type arr);

  view_type view();

  const std::vector<T> &data() const { return d_data; }
#ifndef SWIG
  iterator begin() { return d_data.begin(); }
  iterator end() { return d_data.end(); }
  const_iterator begin() const { return d_data.begin(); }
  const_iterator end() const { return d_data.end(); }
#endif
};

template<typename T>
void print_vec(const ThinVec<T> &v);

void print_offbyone(const ThinVec<int> &INDICES);

