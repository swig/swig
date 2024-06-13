package main

import "strings"
import . "swigtests/exception_memory_leak"

func main() {
	a := NewFoo()
	if FooGet_count() != 1 {
		panic("Foo count not 1")
	}
	b := NewFoo()
	if FooGet_count() != 2 {
		panic("Foo count not 2")
	}

	// Normal behaviour
	Trigger_internal_swig_exception("no problem", a)
	if FooGet_count() != 2 {
		panic("Foo count not 2")
	}
	if FooGet_freearg_count() != 1 {
		panic("Foo count not 1")
	}

	// SWIG exception triggered and handled (return new object case)
	func() {
		defer func() {
			e := recover()
			if strings.Index(e.(string), "Let's") != 0 {
				panic(e.(string))
			}
		}()
		Trigger_internal_swig_exception("null", b)
		panic("Trigger_internal_swig_exception didn't panic")
	}()
	if FooGet_count() != 2 {
		panic("Foo count not 2")
	}
	if FooGet_freearg_count() != 2 {
		panic("Foo count not 2")
	}

	// SWIG exception triggered and handled (return by value case).
	func() {
		defer func() {
			e := recover()
			if strings.Index(e.(string), "Let's") != 0 {
				panic(e.(string))
			}
		}()
		Trigger_internal_swig_exception("null")
		panic("Trigger_internal_swig_exception didn't panic")
	}()
	if FooGet_count() != 2 {
		panic("Foo count not 2")
	}
}
