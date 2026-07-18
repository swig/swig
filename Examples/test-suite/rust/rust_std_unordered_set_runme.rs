mod rust_std_unordered_set;

fn main() {
    let values = rust_std_unordered_set::IntUnorderedSet::new();
    values.insert_value(11);
    values.insert_value(13);

    if values.len() != 2 || values.is_empty() {
        panic!("expected unordered_set len 2, got {}", values.len());
    }
    if values.size() != values.len() {
        panic!("expected size and len to agree");
    }
    if values.count(13) != 1 {
        panic!("expected unordered_set value 13");
    }
    if !values.contains(13) || values.contains(99) {
        panic!("expected unordered_set contains behavior");
    }
    if values.iter().sum::<i32>() != 24 {
        panic!("expected unordered_set iterator sum 24");
    }
    if (&values).into_iter().sum::<i32>() != 24 {
        panic!("expected unordered_set IntoIterator for reference");
    }
    if rust_std_unordered_set::rust_std_unordered_set_sum_values(&values) != 24 {
        panic!("expected unordered_set value sum 24");
    }
    values.erase(11);
    if values.count(11) != 0 {
        panic!("expected erased unordered_set value to be absent");
    }
}
