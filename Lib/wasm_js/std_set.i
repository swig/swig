%include <std_common.i>
namespace std {
  template <class T, class Compare = std::less<T>, class Allocator = std::allocator<T>> class set {
    %wasm_container(std::set<T, Compare, Allocator>)
  public:
    set();
    set(const set &other);
    unsigned long size() const;
    bool empty() const;
    void clear();
    unsigned long erase(T value);
    unsigned long count(T value) const;
    %extend {
      bool insert(T value) { return $self->insert(value).second; }
      bool has(T value) const { return $self->find(value) != $self->end(); }
    }
  };
}
