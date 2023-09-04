%module template_private_assignment

/*
swig-devel mailing list report problem explained 2014-01-07
A setter for the global variable deleted_bits is generated because there is no template
instantiation for the template and hence SWIG does not find the private assignment operator.
SwigValueWrapper is probably on by default for templates that are not instantiated for the
same reason.
*/

%inline %{
template<typename T, typename U> struct DeletedBits {
private:
  DeletedBits& operator=(const DeletedBits&);
};

DeletedBits<int, double> deleted_bits;
%}

// Solution 1: This is a case where an instantiation is required for this to work properly.
%template() DeletedBits<int, double>;

// Solution 2: Alternatively use %immutable
%immutable deleted_bits2;

%inline %{
template<typename T, typename U> struct DeletedBits2 {
private:
  DeletedBits2& operator=(const DeletedBits2&);
};

DeletedBits2<int, double> deleted_bits2;
%}
