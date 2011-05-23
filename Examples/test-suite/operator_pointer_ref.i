%module operator_pointer_ref

%rename(AsCharStarRef) operator char*&;

%inline %{
class MyClass {
public:
    MyClass (const char *s_ = "")
	: s(strdup(s_ ? s_ : ""))
    { }

    ~MyClass () 
    { free(s); }

    operator char*&()
    { return s; }

private:
    char *s;
};
%}
