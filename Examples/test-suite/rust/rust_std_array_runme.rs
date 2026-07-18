mod rust_std_array;

fn main() {
    let values = rust_std_array::IntArray3::new();
    values.fill(4);
    values.setitem(1, 9);

    if values.size() != 3 {
        panic!("expected size 3, got {}", values.size());
    }
    if values.len() != 3 || values.is_empty() {
        panic!("expected array len 3");
    }
    if values.getitemcopy(1) != 9 {
        panic!("expected updated array item");
    }
    if values.iter().sum::<i32>() != 17 {
        panic!("expected array iterator sum 17");
    }
    if (&values).into_iter().collect::<Vec<_>>() != vec![4, 9, 4] {
        panic!("expected array IntoIterator for reference");
    }
    if rust_std_array::rust_std_array_sum(&values) != 17 {
        panic!("expected array sum 17");
    }
}
