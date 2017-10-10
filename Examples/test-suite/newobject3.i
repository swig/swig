/**
 * Regression test for PHP bug: https://sourceforge.net/p/swig/bugs/1350/
 */

%module newobject3

%newobject factory::create;
%inline %{
class Product {};
class factory {
public:
    Product * create(short id, short type = 0);
    Product * create(const char * name, short type = 0);
};
%}

%{
Product * factory::create(short id, short type) {
    return (id && type >= 0) ? new Product : NULL;
}

Product * factory::create(const char * name, short type) {
    return (name && type >= 0) ? new Product : NULL;
}
%}
