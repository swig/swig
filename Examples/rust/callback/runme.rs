mod messages;

use messages::{DeviceService, DeviceServiceDirector, DeviceServiceDirectorOwned};
use std::os::raw::c_int;

struct CallbackService {
    enabled: bool,
    last_id: String,
    last_value: c_int,
}

impl DeviceServiceDirector for CallbackService {
    fn cmdEnableDevice(&mut self, enabled: bool) {
        self.enabled = enabled;
    }

    fn cmdSetValue(&mut self, id: String, value: c_int) {
        self.last_id = id;
        self.last_value = value;
    }
}

fn main() {
    let mut service = DeviceServiceDirectorOwned::from_proxy(
        DeviceService::new(),
        CallbackService {
            enabled: false,
            last_id: String::new(),
            last_value: 0,
        },
    );
    let bus = messages::DeviceBus::create(Some(service.as_proxy_mut())).expect("expected DeviceBus");

    bus.sendEnable(true);
    bus.sendValue("temperature".to_string(), 23);

    if !service.director().enabled {
        panic!("expected enable callback");
    }
    if service.director().last_id != "temperature" || service.director().last_value != 23 {
        panic!("expected value callback");
    }
}
