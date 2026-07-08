mod rust_std_map;

fn main() {
    let values = rust_std_map::IntIntMap::new();
    values.setitem(2, 20);
    values.setitem(3, 30);

    if values.len() != 2 || values.is_empty() {
        panic!("expected map len 2, got {}", values.len());
    }
    if values.size() != values.len() {
        panic!("expected size and len to agree");
    }
    if values.getitem(3) != 30 {
        panic!("expected map value 30");
    }
    if values.get(3) != Some(30) || values.get(9).is_some() {
        panic!("expected map get Option behavior");
    }
    if !values.contains_key(2) || values.contains_key(9) {
        panic!("expected map contains_key behavior");
    }
    if values.keys().sum::<i32>() != 5 {
        panic!("expected map key iterator sum");
    }
    if values.values().sum::<i32>() != 50 {
        panic!("expected map value iterator sum");
    }
    if values.iter().map(|(key, value)| key * value).sum::<i32>() != 130 {
        panic!("expected map pair iterator");
    }
    if (&values).into_iter().map(|(_key, value)| value).sum::<i32>() != 50 {
        panic!("expected map IntoIterator for reference");
    }
    if rust_std_map::rust_std_map_sum_values(&values) != 50 {
        panic!("expected map value sum 50");
    }
    values.erase(2);
    if values.count(2) != 0 {
        panic!("expected erased map key to be absent");
    }
}
