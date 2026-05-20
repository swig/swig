%module template_default_pointer

%inline %{

template <class T1, class T2 = T1*>
class B
{
};

template <class T = int*>
class C
{
};

template <class T = void*>
class D
{
};

template <class T = const int*>
class E
{
};

template <class T = int**>
class F
{
};

template <class T = int&>
class G
{
};

template <class T = int&&>
class H
{
};

%}

%template(B_d) B<double>;
%template(C_i) C<int>;
%template(D_v) D<void>;
%template(E_ci) E<const int>;
%template(F_i) F<int>;
%template(G_i) G<int>;
%template(H_i) H<int>;
