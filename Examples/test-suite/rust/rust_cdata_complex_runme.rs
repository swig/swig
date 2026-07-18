mod rust_cdata_complex;

fn main() {
    let bytes = [2_u8, 3, 5, 7];
    if rust_cdata_complex::rust_count_bytes(&bytes) != 17 {
        panic!("expected byte sum 17");
    }

    let shifted = rust_cdata_complex::rust_shift_complex(rust_cdata_complex::RustComplex {
        real: 4.0,
        imag: 9.0,
    });
    if shifted.real != 5.5 || shifted.imag != 7.0 {
        panic!("unexpected complex value");
    }

    let data = rust_cdata_complex::rust_make_cdata();
    if data != vec![9, 8, 7, 6] {
        panic!("unexpected cdata contents");
    }
}
