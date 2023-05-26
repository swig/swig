var extend_placement = require("extend_placement");

foo = new extend_placement.Foo();
foo = new extend_placement.Foo(1);
foo = new extend_placement.Foo(1, 1);
foo.spam();
foo.spam("hello");
foo.spam(1);
foo.spam(1, 1);
foo.spam(1, 1, 1);
foo.spam(new extend_placement.Foo());
foo.spam(new extend_placement.Foo(), 1.0);


bar = new extend_placement.Bar();
bar = new extend_placement.Bar(1);
bar.spam();
bar.spam("hello");
bar.spam(1);
bar.spam(1, 1);
bar.spam(1, 1, 1);
bar.spam(new extend_placement.Bar());
bar.spam(new extend_placement.Bar(), 1.0);


foo = new extend_placement.FooTi();
foo = new extend_placement.FooTi(1);
foo = new extend_placement.FooTi(1, 1);
foo.spam();
foo.spam("hello");
foo.spam(1);
foo.spam(1, 1);
foo.spam(1, 1, 1);
foo.spam(new extend_placement.Foo());
foo.spam(new extend_placement.Foo(), 1.0);


bar = new extend_placement.BarTi();
bar = new extend_placement.BarTi(1);
bar.spam();
bar.spam("hello");
bar.spam(1);
bar.spam(1, 1);
bar.spam(1, 1, 1);
bar.spam(new extend_placement.Bar());
bar.spam(new extend_placement.Bar(), 1.0);
