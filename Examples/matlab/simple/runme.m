assert(matlab_example.add(2, 3) == 5);
counter = matlab_example.Counter(10);
assert(counter.increment() == 11);
assert(counter.value() == 11);
counter.value(20);
assert(counter.increment() == 21);
delete(counter);
