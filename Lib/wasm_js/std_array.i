%include <std_common.i>
namespace std {
  template <class T, unsigned long N> struct array {
    %wasm_container(std::array<T, N>)
    array();
    array(const array &other);
    unsigned long size() const;
    bool empty() const;
    void fill(T value);
    %extend {
      T at(unsigned long index) const { return $self->at(index); }
      void set(unsigned long index, T value) { $self->at(index) = value; }
    }
  };
}
