%include <std_common.i>
namespace std {
  template <class K, class V, class Compare = std::less<K>, class Allocator = std::allocator<std::pair<const K, V> >> class map {
    %wasm_container(std::map<K, V, Compare, Allocator>)
  public:
    map();
    map(const map &other);
    unsigned long size() const;
    bool empty() const;
    void clear();
    unsigned long erase(K key);
    unsigned long count(K key) const;
    %extend {
      V get(K key) const {
        typename std::map<K, V, Compare, Allocator>::const_iterator it = $self->find(key);
        if (it == $self->end()) throw std::out_of_range("map key not found");
        return it->second;
      }
      void set(K key, V value) { (*$self)[key] = value; }
      bool has(K key) const { return $self->find(key) != $self->end(); }
    }
  };
}
