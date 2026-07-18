mod director_pass_by_value;

use director_pass_by_value::{
    Caller, DirectorPassByValueAbstractBase, DirectorPassByValueAbstractBaseDirector, DirectorPassByValueAbstractBaseDirectorOwned,
    PassedByValue,
};

struct RustPassByValue {
    value: Option<PassedByValue>,
}

impl DirectorPassByValueAbstractBaseDirector for RustPassByValue {
    fn virtualMethod(&mut self, pbv: PassedByValue) {
        self.value = Some(pbv);
    }

    fn virtualConstMethod(&mut self, pbv: PassedByValue) {
        self.value = Some(pbv);
    }
}

fn main() {
    let caller = Caller::new();
    let mut receiver = DirectorPassByValueAbstractBaseDirectorOwned::from_proxy(
        DirectorPassByValueAbstractBase::new(),
        RustPassByValue { value: None },
    );

    caller.call_virtualMethod(receiver.as_proxy_mut());

    let value = receiver
        .director()
        .value
        .as_ref()
        .expect("expected pass-by-value director argument");
    if value.getVal() != 0x12345678 {
        panic!("bad pass-by-value director argument");
    }
}
