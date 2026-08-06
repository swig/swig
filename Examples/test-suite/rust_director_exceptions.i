%module(directors="1") rust_director_exceptions

%feature("director") PanicReceiver;

%inline %{
#include <exception>
#include <string>

class PanicReceiver {
public:
  PanicReceiver() : last(0) {
  }
  virtual ~PanicReceiver() {
  }
  virtual int value(int input) {
    return input;
  }
  virtual void record(int input) {
    last = input;
  }
  virtual int status() {
    return 0;
  }
  int call_value_catch() {
    try {
      return value(5);
    } catch (const std::exception &e) {
      std::string message(e.what());
      return message.find("rust director value panic") != std::string::npos ? 77 : -1;
    }
  }
  int call_record_catch() {
    try {
      record(6);
      return last;
    } catch (const std::exception &e) {
      std::string message(e.what());
      return message.find("rust director record panic") != std::string::npos ? 88 : -1;
    }
  }
  int call_status_catch() {
    try {
      return status();
    } catch (const std::exception &e) {
      std::string message(e.what());
      return message.find("CallbackError: rust director structured error") != std::string::npos ? 99 : -1;
    }
  }
private:
  int last;
};

%}
