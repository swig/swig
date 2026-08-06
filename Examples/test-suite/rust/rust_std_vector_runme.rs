mod rust_std_vector;

fn main() {
    let values = rust_std_vector::IntVector::new();
    values.push_back(10);
    values.push_back(20);
    values.push_back(12);

    if values.len() != 3 || values.is_empty() {
        panic!("expected len 3, got {}", values.len());
    }
    if values.indices().sum::<usize>() != 3 {
        panic!("expected vector index range");
    }
    if values.iter().sum::<i32>() != 42 {
        panic!("expected vector iterator sum 42");
    }
    if (&values).into_iter().collect::<Vec<_>>() != vec![10, 20, 12] {
        panic!("expected IntoIterator for vector reference");
    }
    if values.size() != values.len() {
        panic!("expected size and len to agree");
    }
    if rust_std_vector::vector_sum(&values) != 42 {
        panic!("expected vector sum 42");
    }
}
