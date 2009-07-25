%module cpp0x_rvalue_reference

%inline %{
class A {
public:
        int  getAcopy() { return _a; }
        int *getAptr()  { return &_a; }
        int &getAref()  { return _a; }
        int &&getAmove() { return _a; }

        void setAcopy(int a) { _a = a; }
        void setAptr(int *a)  { _a = *a; }
        void setAref(int &a)  { _a = a; }
        void setAmove(int &&a) { _a = a; }

        void arg(int a);
        void arg(int *a);
        void arg(int &a);
//        void arg(int &&a); // redefinition not allowed
private:
        int _a;
};
%}
