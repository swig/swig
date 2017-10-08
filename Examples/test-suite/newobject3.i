/**
 * Regression test for PHP bug: https://sourceforge.net/p/swig/bugs/1350/
 */

%module newobject3

%newobject factory::create;
%inline %{
class product {};
class factory {
public:
    product * create(short id, short type = 0);
    product * create(const char * name, short type = 0);
};
%}

%{
product * factory::create(short id, short type) {
    return (id && type >= 0) ? new product : NULL;
}

product * factory::create(const char * name, short type) {
    return (name && type >= 0) ? new product : NULL;
}
%}
