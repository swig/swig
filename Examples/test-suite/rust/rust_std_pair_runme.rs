mod rust_std_pair;

fn main() {
    let pair = rust_std_pair::rust_std_pair_make(8, 13);
    if rust_std_pair::rust_std_pair_sum(&pair) != 21 {
        panic!("expected pair sum 21");
    }
}
