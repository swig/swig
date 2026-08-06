%module(directors="1") rust_director_create_callback

%feature("director") MessageReceiver;
%newobject MessageService::create;

%inline %{

class MessageReceiver {
public:
  MessageReceiver() {
  }
  virtual ~MessageReceiver() {
  }
  virtual int receive(int message) {
    return message;
  }
};

class MessageBus {
public:
  MessageBus() : receiver(0) {
  }
  void create(MessageReceiver *callback) {
    receiver = callback;
  }
  int dispatch(int message) {
    return receiver ? receiver->receive(message) : -1;
  }
  MessageReceiver *current() {
    return receiver;
  }
  MessageReceiver &current_ref() {
    return *receiver;
  }
  void clear() {
    receiver = 0;
  }
private:
  MessageReceiver *receiver;
};

class MessageService {
public:
  static MessageService *create(MessageReceiver *callback) {
    return new MessageService(callback);
  }
  ~MessageService() {
  }
  int dispatch(int message) {
    return receiver ? receiver->receive(message) : -1;
  }
  MessageReceiver *current() {
    return receiver;
  }
private:
  MessageService(MessageReceiver *callback) : receiver(callback) {
  }
  MessageReceiver *receiver;
};

%}
