mod rust_std_set;

fn main() {
    let values = rust_std_set::IntSet::new();
    values.insert_value(7);
    values.insert_value(2);
    values.insert_value(7);

    if values.len() != 2 || values.is_empty() {
        panic!("expected unique set len 2, got {}", values.len());
    }
    if values.size() != values.len() {
        panic!("expected size and len to agree");
    }
    if values.count(7) != 1 {
        panic!("expected set to contain 7");
    }
    if !values.contains(7) || values.contains(99) {
        panic!("expected set contains behavior");
    }
    if values.iter().sum::<i32>() != 9 {
        panic!("expected set iterator sum 9");
    }
    if (&values).into_iter().sum::<i32>() != 9 {
        panic!("expected set IntoIterator for reference");
    }
    if rust_std_set::rust_std_set_sum(&values) != 9 {
        panic!("expected set sum 9");
    }
    values.erase(2);
    if values.count(2) != 0 {
        panic!("expected erased value to be absent");
    }
}
