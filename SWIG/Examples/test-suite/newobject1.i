%module newobject1

%newobject Foo::makeFoo();

%inline %{
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
%}

%{
// Static member initialization (not wrapped)
int Foo::m_fooCount = 0;
%}
