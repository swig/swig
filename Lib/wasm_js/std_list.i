%include <std_common.i>
namespace std {
  template <class T, class Allocator = std::allocator<T> > class list {
    %wasm_container(std::list<T, Allocator>)
  public:
    typedef T value_type;
    list();
    list(unsigned long count);
    list(unsigned long count, T value);
    list(const list &other);
    unsigned long size() const;
    bool empty() const;
    void clear();
    void push_back(T value);
    void push_front(T value);
    void resize(unsigned long count);
    void resize(unsigned long count, T value);
    void assign(unsigned long count, T value);
    %extend {
      void pop_front() {
        if ($self->empty()) throw std::out_of_range("empty sequence");
        $self->pop_front();
      }
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
        typename std::list<T, Allocator>::iterator it = $self->begin();
        std::advance(it, index);
        $self->insert(it, value);
      }
      void erase(unsigned long index) {
        if (index >= $self->size()) throw std::out_of_range("sequence index out of range");
        typename std::list<T, Allocator>::iterator it = $self->begin();
        std::advance(it, index);
        $self->erase(it);
      }
      T at(unsigned long index) const {
        if (index >= $self->size()) throw std::out_of_range("sequence index out of range");
        typename std::list<T, Allocator>::const_iterator it = $self->begin();
        std::advance(it, index);
        return *it;
      }
      void set(unsigned long index, T value) {
        if (index >= $self->size()) throw std::out_of_range("sequence index out of range");
        typename std::list<T, Allocator>::iterator it = $self->begin();
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
