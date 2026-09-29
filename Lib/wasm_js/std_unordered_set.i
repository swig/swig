%include <std_common.i>
namespace std {
  template <class T, class Hash = std::hash<T>, class Equal = std::equal_to<T>, class Allocator = std::allocator<T>> class unordered_set {
    %wasm_container(std::unordered_set<T, Hash, Equal, Allocator>)
  public:
    unordered_set();
    unordered_set(const unordered_set &other);
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
