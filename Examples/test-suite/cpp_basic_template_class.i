%module cpp_basic_template_class

%inline
{

template<typename T> struct MyTemplateClass {
    T someMemberVariable;
};

}

%template(MyTemplateClass_Int) MyTemplateClass<int>;