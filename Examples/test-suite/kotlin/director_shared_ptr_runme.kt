@file:JvmName("director_shared_ptr_runme")

import director_shared_ptr.*

class director_shared_ptr_MyBarFoo : director_shared_ptr.Foo() {
    override fun ping(): String {
        return "director_shared_ptr_MyBarFoo.ping()"
    }

    override fun pong(): String {
        return "director_shared_ptr_MyBarFoo.pong();" + ping()
    }

    override fun upcall(fooBarPtr: director_shared_ptr.FooBar?): String {
        return "override;" + fooBarPtr!!.FooBarDo()
    }

    override fun makeFoo(): director_shared_ptr.Foo {
        return director_shared_ptr.Foo()
    }
}

class director_shared_ptr_MyBarFooDerived : director_shared_ptr.FooDerived() {
    override fun ping(): String {
        return "director_shared_ptr_MyBarFooDerived.ping()"
    }

    override fun pong(): String {
        return "director_shared_ptr_MyBarFooDerived.pong();" + ping()
    }

    override fun upcall(fooBarPtr: director_shared_ptr.FooBar?): String {
        return "overrideDerived;" + fooBarPtr!!.FooBarDo()
    }

    override fun makeFoo(): director_shared_ptr.Foo {
        return director_shared_ptr.Foo()
    }
}

fun check(got: String, expected: String) {
    if (got != expected) {
        throw RuntimeException("Failed, got: " + got + " expected: " + expected)
    }
}

fun main() {
    try {
        System.loadLibrary("director_shared_ptr")
    } catch (e: UnsatisfiedLinkError) {
        System.err.println("Native code library failed to load. See the chapter on Dynamic Linking Problems in the SWIG Java documentation for help.\n" + e)
        kotlin.system.exitProcess(1)
    }

    val fooBar = director_shared_ptr.FooBar()

    val myBarFoo: director_shared_ptr.Foo = director_shared_ptr_MyBarFoo()
    check(myBarFoo.ping(), "director_shared_ptr_MyBarFoo.ping()")
    check(director_shared_ptr.Foo.callPong(myBarFoo), "director_shared_ptr_MyBarFoo.pong();director_shared_ptr_MyBarFoo.ping()")
    check(director_shared_ptr.Foo.callUpcall(myBarFoo, fooBar), "override;Bar::Foo2::Foo2Bar()")

    val myFoo: director_shared_ptr.Foo = myBarFoo.makeFoo()
    check(myFoo.pong(), "Foo::pong();Foo::ping()")
    check(director_shared_ptr.Foo.callPong(myFoo), "Foo::pong();Foo::ping()")
    check(myFoo.upcall(fooBar), "Bar::Foo2::Foo2Bar()")

    val myFoo2: director_shared_ptr.Foo = director_shared_ptr.Foo().makeFoo()
    check(myFoo2.pong(), "Foo::pong();Foo::ping()")
    check(director_shared_ptr.Foo.callPong(myFoo2), "Foo::pong();Foo::ping()")

    val myBarFooDerived: director_shared_ptr.FooDerived = director_shared_ptr_MyBarFooDerived()
    check(myBarFooDerived.ping(), "director_shared_ptr_MyBarFooDerived.ping()")
    check(director_shared_ptr.FooDerived.callPong(myBarFooDerived), "director_shared_ptr_MyBarFooDerived.pong();director_shared_ptr_MyBarFooDerived.ping()")
    check(director_shared_ptr.FooDerived.callUpcall(myBarFooDerived, fooBar), "overrideDerived;Bar::Foo2::Foo2Bar()")

    val myFoo3: director_shared_ptr.Foo = myBarFoo.makeFoo()
    myFoo3.swigReleaseOwnership()
    myFoo3.swigTakeOwnership()
    val myBarFooDerived2: director_shared_ptr.FooDerived = director_shared_ptr_MyBarFooDerived()
    myBarFooDerived2.swigReleaseOwnership()
    myBarFooDerived2.swigTakeOwnership()
}
