mod director_minimal;

use director_minimal::MinimalDirectorHandle;

struct MyMinimal {
    calls: usize,
}

impl director_minimal::MinimalDirector for MyMinimal {
    fn run(&mut self) -> bool {
        self.calls += 1;
        true
    }
}

fn main() {
    let minimal = director_minimal::Minimal::new();
    let handle = MinimalDirectorHandle::connect(&minimal, MyMinimal { calls: 0 });

    if !minimal.get() {
        panic!("expected director override to return true");
    }
    if !handle.is_connected() {
        panic!("expected director handle to be connected");
    }
    if handle.director().calls != 1 {
        panic!("expected one director call, got {}", handle.director().calls);
    }
}
