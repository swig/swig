mod rust_std_unordered_map;

fn main() {
    let values = rust_std_unordered_map::IntIntUnorderedMap::new();
    values.setitem(5, 50);
    values.setitem(7, 70);

    if values.len() != 2 || values.is_empty() {
        panic!("expected unordered_map len 2, got {}", values.len());
    }
    if values.size() != values.len() {
        panic!("expected size and len to agree");
    }
    if values.getitem(7) != 70 {
        panic!("expected unordered_map value 70");
    }
    if values.get(7) != Some(70) || values.get(99).is_some() {
        panic!("expected unordered_map get Option behavior");
    }
    if !values.contains_key(5) || values.contains_key(99) {
        panic!("expected unordered_map contains_key behavior");
    }
    if values.keys().sum::<i32>() != 12 {
        panic!("expected unordered_map key iterator sum");
    }
    if values.values().sum::<i32>() != 120 {
        panic!("expected unordered_map value iterator sum");
    }
    if values.iter().map(|(key, value)| key * value).sum::<i32>() != 740 {
        panic!("expected unordered_map pair iterator");
    }
    if (&values).into_iter().map(|(_key, value)| value).sum::<i32>() != 120 {
        panic!("expected unordered_map IntoIterator for reference");
    }
    if rust_std_unordered_map::rust_std_unordered_map_sum_values(&values) != 120 {
        panic!("expected unordered_map value sum 120");
    }
    values.erase(5);
    if values.count(5) != 0 {
        panic!("expected erased unordered_map key to be absent");
    }
}
