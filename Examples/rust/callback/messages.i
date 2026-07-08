%module(directors="1") messages
%feature("director") DeviceService;

%include <std_string.i>

%inline %{
#include <string>

class DeviceService {
public:
  DeviceService() : last_enabled(false), last_value(0) {
  }
  virtual ~DeviceService() {
  }
  virtual void cmdEnableDevice(bool enabled) {
    last_enabled = enabled;
  }
  virtual void cmdSetValue(const std::string &id, int value) {
    last_id = id;
    last_value = value;
  }
  bool last_enabled;
  std::string last_id;
  int last_value;
};

class DeviceBus {
public:
  DeviceBus() : service(0) {
  }
  static DeviceBus *create(DeviceService *service) {
    DeviceBus *bus = new DeviceBus();
    bus->service = service;
    return bus;
  }
  void sendEnable(bool enabled) {
    if (service)
      service->cmdEnableDevice(enabled);
  }
  void sendValue(const std::string &id, int value) {
    if (service)
      service->cmdSetValue(id, value);
  }
private:
  DeviceService *service;
};
%}
