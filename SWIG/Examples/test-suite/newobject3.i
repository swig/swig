%module newobject3

%newobject makeFoo();

%{
class Foo
{
private:
    Foo(const Foo&);
    Foo& operator=(const Foo&);
private:
    static int m_fooCount;
protected:
    Foo() {
        m_fooCount++;
    }
public:
    // Factory function
    static Foo *makeFoo() {
        return new Foo;
    }
    
    // Return the number of instances
    static int fooCount() {
        return m_fooCount;
    }
    
    // Destructor
    ~Foo() {
        m_fooCount--;
    }
};

// Static member initialization (not wrapped)
int Foo::m_fooCount = 0;
%}

/**
 * Don't wrap the class itself; just these two global functions.
 */

%inline %{
Foo *makeFoo() {
    return Foo::makeFoo();
}

int fooCount() {
    return Foo::fooCount();
}
%}
