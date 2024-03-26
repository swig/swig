%module cpp11_smart_pointer_compatibility

// This test is specific to shared pointers in Node-API
// In Node-API, an std::shared_ptr behaves an identical way as 
// its base object

%include <std_shared_ptr.i>
%include <std_unique_ptr.i>

%shared_ptr(Integer);
%unique_ptr(Integer);

%inline %{
class Integer {
  int value;
public:
  Integer(): value() {}
  Integer(int v): value(v) {}
  int get() const { return value; }
  void set(int v) { value = v; }
};

std::shared_ptr<Integer> ProduceSharedPointer(int v) {
  return std::shared_ptr<Integer>(new Integer(v));
}
void ProduceSharedPointerRef(std::shared_ptr<Integer> &OUTPUT, int v) {
  OUTPUT = std::shared_ptr<Integer>(new Integer(v));
}
// This works because of mandatory copy-elision
std::unique_ptr<Integer> ProduceUniquePointer(int v) {
  return std::unique_ptr<Integer>(new Integer(v));
}

int ConsumePlainObject(Integer v) {
  return v.get();
}
int ConsumeConstReference(const Integer &v) {
  return v.get();
}
int ConsumePointer(Integer *v) {
  return v->get();
}
int ConsumeSharedPointer(std::shared_ptr<Integer> v) {
  return v->get();
}
int ConsumeSharedPointerReference(std::shared_ptr<Integer> &v) {
  return v->get();
}
int ConsumeUniquePtr(std::unique_ptr<Integer> &&v) {
  return v->get();
}

%}
