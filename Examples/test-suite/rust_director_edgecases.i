%module(directors="1") rust_director_edgecases

%feature("director") EdgeReceiver;

%inline %{

class EdgePayload {
public:
  EdgePayload(int value) : value_(value) {
  }
  int value() const {
    return value_;
  }
  void set_value(int value) {
    value_ = value;
  }
private:
  int value_;
};

class EdgeReceiver {
public:
  virtual ~EdgeReceiver() {
  }
  virtual int overloaded(int value) {
    return value;
  }
  virtual int overloaded(EdgePayload *payload) {
    return payload ? payload->value() : -1;
  }
  virtual int observe(const EdgePayload *payload) {
    return payload ? payload->value() : -1;
  }
  virtual void mutate(EdgePayload &payload) {
    payload.set_value(payload.value() + 1);
  }
  virtual EdgePayload *choose(EdgePayload *payload) {
    return payload;
  }
};

int call_overloaded_int(EdgeReceiver *receiver, int value) {
  return receiver->overloaded(value);
}

int call_overloaded_payload(EdgeReceiver *receiver, EdgePayload *payload) {
  return receiver->overloaded(payload);
}

int call_observe(EdgeReceiver *receiver, const EdgePayload *payload) {
  return receiver->observe(payload);
}

void call_mutate(EdgeReceiver *receiver, EdgePayload &payload) {
  receiver->mutate(payload);
}

EdgePayload *call_choose(EdgeReceiver *receiver, EdgePayload *payload) {
  return receiver->choose(payload);
}

%}
