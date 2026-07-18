mod rust_enums;

use rust_enums::{
    RustColor, RustEnumBox, RustEnumBox_Mode, RustEnumDirector, RustEnumDirectorDirector, RustEnumDirectorDirectorOwned, RustSigned,
};
use std::convert::TryFrom;

struct EnumCallbacks {
    seen_color: RustColor,
    seen_signed: RustSigned,
}

impl RustEnumDirectorDirector for EnumCallbacks {
    fn choose(&mut self, color: RustColor) -> RustColor {
        self.seen_color = color;
        match color {
            RustColor::RustRed => RustColor::RustCyan,
            RustColor::RustGreen => RustColor::RustMagenta,
            _ => RustColor::RustBlue,
        }
    }

    fn choose_signed(&mut self, value: RustSigned) -> RustSigned {
        self.seen_signed = value;
        match value {
            RustSigned::RustNegative => RustSigned::RustLarge,
            _ => RustSigned::RustNegative,
        }
    }
}

fn main() {
    if rust_enums::rust_next_color(RustColor::RustRed) != RustColor::RustGreen {
        panic!("expected RustRed to advance to RustGreen");
    }
    if rust_enums::rust_next_color(RustColor::RustGreen) != RustColor::RustBlue {
        panic!("expected RustGreen to advance to RustBlue");
    }
    assert_eq!(rust_enums::rust_color_value(RustColor::RustMagenta), 13);
    assert_eq!(rust_enums::rust_color_ref(RustColor::RustCyan), RustColor::RustCyan);
    assert_eq!(RustColor::from_i32(1), Some(RustColor::RustRed));
    assert_eq!(RustColor::from_i32(99), None);
    assert_eq!(RustColor::try_from(13).unwrap(), RustColor::RustMagenta);
    assert!(RustColor::try_from(99).is_err());
    assert_eq!(RustColor::RustBlue.value(), 3);
    assert_eq!(RustSigned::RustNegative.value(), -7);
    assert!(rust_enums::try_rust_color_from_int(99).is_err());

    let boxed = RustEnumBox::new();
    assert_eq!(boxed.color(), RustColor::RustRed);
    boxed.set_color(RustColor::RustCyan);
    assert_eq!(boxed.color(), RustColor::RustCyan);
    assert_eq!(boxed.select(RustColor::RustGreen), RustColor::RustBlue);
    assert_eq!(boxed.signed_value(), RustSigned::RustZero);
    boxed.set_signed_value(RustSigned::RustLarge);
    assert_eq!(boxed.signed_value(), RustSigned::RustLarge);
    assert_eq!(boxed.select_signed(RustSigned::RustNegative), RustSigned::RustLarge);

    assert_eq!(boxed.mode(), RustEnumBox_Mode::ModeIdle);
    boxed.set_mode(RustEnumBox_Mode::ModeRunning);
    assert_eq!(boxed.mode(), RustEnumBox_Mode::ModeRunning);
    assert_eq!(RustEnumBox::next_mode(RustEnumBox_Mode::ModeIdle), RustEnumBox_Mode::ModeRunning);
    assert_eq!(RustEnumBox_Mode::from_i32(20), Some(RustEnumBox_Mode::ModeStopped));
    assert!(RustEnumBox_Mode::try_from(777).is_err());

    let mut director = RustEnumDirectorDirectorOwned::from_proxy(
        RustEnumDirector::new(),
        EnumCallbacks {
            seen_color: RustColor::RustRed,
            seen_signed: RustSigned::RustZero,
        },
    );
    assert_eq!(
        rust_enums::rust_call_choose(Some(director.as_proxy_mut()), RustColor::RustRed),
        RustColor::RustCyan
    );
    assert_eq!(director.director().seen_color, RustColor::RustRed);
    assert_eq!(
        rust_enums::rust_call_choose_signed(Some(director.as_proxy_mut()), RustSigned::RustNegative),
        RustSigned::RustLarge
    );
    assert_eq!(director.director().seen_signed, RustSigned::RustNegative);
}
