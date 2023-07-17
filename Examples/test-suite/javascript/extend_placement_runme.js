var extend_placement = require("extend_placement");

var foo = new extend_placement.Foo();
foo = new extend_placement.Foo(1);
foo = new extend_placement.Foo(1, 1);
/* await */(foo.spam());
/* await */(foo.spam("hello"));
/* await */(foo.spam(1));
/* await */(foo.spam(1, 1));
/* await */(foo.spam(1, 1, 1));
/* await */(foo.spam(new extend_placement.Foo()));
/* await */(foo.spam(new extend_placement.Foo(), 1.0));


var bar = new extend_placement.Bar();
bar = new extend_placement.Bar(1);
/* await */(bar.spam());
/* await */(bar.spam("hello"));
/* await */(bar.spam(1));
/* await */(bar.spam(1, 1));
/* await */(bar.spam(1, 1, 1));
/* await */(bar.spam(new extend_placement.Bar()));
/* await */(bar.spam(new extend_placement.Bar(), 1.0));


foo = new extend_placement.FooTi();
foo = new extend_placement.FooTi(1);
foo = new extend_placement.FooTi(1, 1);
/* await */(foo.spam());
/* await */(foo.spam("hello"));
/* await */(foo.spam(1));
/* await */(foo.spam(1, 1));
/* await */(foo.spam(1, 1, 1));
/* await */(foo.spam(new extend_placement.Foo()));
/* await */(foo.spam(new extend_placement.Foo(), 1.0));


bar = new extend_placement.BarTi();
bar = new extend_placement.BarTi(1);
/* await */(bar.spam());
/* await */(bar.spam("hello"));
/* await */(bar.spam(1));
/* await */(bar.spam(1, 1));
/* await */(bar.spam(1, 1, 1));
/* await */(bar.spam(new extend_placement.Bar()));
/* await */(bar.spam(new extend_placement.Bar(), 1.0));
