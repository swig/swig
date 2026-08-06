%module(directors="1") messages
%feature("director") Receiver;

%inline %{
class Receiver {
public:
  Receiver() : last(0) {
  }
  virtual ~Receiver() {
  }
  virtual void message(int value) {
    last = value;
  }
  int last;
};

inline void deliver(Receiver *receiver, int value) {
  receiver->message(value);
}
%}
