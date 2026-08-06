mod rust_std_deque;

fn main() {
    let values = rust_std_deque::IntDeque::new();
    values.push_back(3);
    values.push_front(2);
    values.push_back(5);
    values.setitem(1, 7);

    if values.len() != 3 || values.is_empty() {
        panic!("expected len 3, got {}", values.len());
    }
    if values.indices().sum::<usize>() != 3 {
        panic!("expected deque index range");
    }
    if values.iter().sum::<i32>() != 14 {
        panic!("expected deque iterator sum 14");
    }
    if (&values).into_iter().collect::<Vec<_>>() != vec![2, 7, 5] {
        panic!("expected IntoIterator for deque reference");
    }
    if values.size() != values.len() {
        panic!("expected size and len to agree");
    }
    if values.getitemcopy(1) != 7 {
        panic!("expected updated deque item");
    }
    if rust_std_deque::rust_std_deque_sum(&values) != 14 {
        panic!("expected deque sum 14");
    }
}
