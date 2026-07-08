mod rust_std_list;

fn main() {
    let values = rust_std_list::IntList::new();
    values.push_back(3);
    values.push_front(2);
    values.push_back(5);

    if values.len() != 3 || values.is_empty() {
        panic!("expected len 3, got {}", values.len());
    }
    if values.size() != values.len() {
        panic!("expected size and len to agree");
    }
    if values.indices().sum::<usize>() != 3 {
        panic!("expected list index range");
    }
    if values.iter().sum::<i32>() != 10 {
        panic!("expected list iterator sum 10");
    }
    if (&values).into_iter().collect::<Vec<_>>() != vec![2, 3, 5] {
        panic!("expected IntoIterator for list reference");
    }
    if rust_std_list::rust_std_list_sum(&values) != 10 {
        panic!("expected list sum 10");
    }
    values.reverse();
    values.remove(3);
    if values.len() != 2 {
        panic!("expected size 2 after remove");
    }
}
