%include <std_common.i>
namespace std {
  template <class T, class Allocator = std::allocator<T> > class vector {
    %wasm_container(std::vector<T, Allocator>)
  public:
    typedef T value_type;
    vector();
    vector(unsigned long count);
    vector(unsigned long count, T value);
    vector(const vector &other);
    unsigned long size() const;
    bool empty() const;
    void clear();
    void push_back(T value);
    void resize(unsigned long count);
    void resize(unsigned long count, T value);
    void assign(unsigned long count, T value);
    unsigned long capacity() const;
    void reserve(unsigned long count);
    %extend {
      T front() const {
        if ($self->empty()) throw std::out_of_range("empty sequence");
        return $self->front();
      }
      T back() const {
        if ($self->empty()) throw std::out_of_range("empty sequence");
        return $self->back();
      }
      void insert(unsigned long index, T value) {
        if (index > $self->size()) throw std::out_of_range("sequence index out of range");
        typename std::vector<T, Allocator>::iterator it = $self->begin();
        std::advance(it, index);
        $self->insert(it, value);
      }
      void erase(unsigned long index) {
        if (index >= $self->size()) throw std::out_of_range("sequence index out of range");
        typename std::vector<T, Allocator>::iterator it = $self->begin();
        std::advance(it, index);
        $self->erase(it);
      }
      T at(unsigned long index) const {
        if (index >= $self->size()) throw std::out_of_range("sequence index out of range");
        typename std::vector<T, Allocator>::const_iterator it = $self->begin();
        std::advance(it, index);
        return *it;
      }
      void set(unsigned long index, T value) {
        if (index >= $self->size()) throw std::out_of_range("sequence index out of range");
        typename std::vector<T, Allocator>::iterator it = $self->begin();
        std::advance(it, index);
        *it = value;
      }
      void pop_back() {
        if ($self->empty()) throw std::out_of_range("empty sequence");
        $self->pop_back();
      }
    }
  };
}
