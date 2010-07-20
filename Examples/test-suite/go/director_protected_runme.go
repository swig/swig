package main

import . "./director_protected"

type FooBar struct{} // From Bar
func (p *FooBar) Ping() string {
	return "FooBar::ping();"
}

type FooBar2 struct{} // From Bar
func (p *FooBar2) Ping() string {
	return "FooBar2::ping();"
}
func (p *FooBar2) Pang() string {
	return "FooBar2::pang();"
}

func main() {
	b := NewBar()
	f := b.Create()
	fb := NewDirectorBar(&FooBar{})
	fb2 := NewDirectorBar(&FooBar2{})

	s := fb.Used()
	if s != "Foo::pang();Bar::pong();Foo::pong();FooBar::ping();" {
		panic(0)
	}

	s = fb2.Used()
	if s != "FooBar2::pang();Bar::pong();Foo::pong();FooBar2::ping();" {
		panic(0)
	}

	s = b.Pong()
	if s != "Bar::pong();Foo::pong();Bar::ping();" {
		panic(0)
	}

	s = f.Pong()
	if s != "Bar::pong();Foo::pong();Bar::ping();" {
		panic(0)
	}

	s = fb.Pong()
	if s != "Bar::pong();Foo::pong();FooBar::ping();" {
		panic(0)
	}
}
