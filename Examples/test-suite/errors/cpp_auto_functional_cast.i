%module xxx

// Not deduced: a call rather than a functional cast, and a member of a functional cast.
struct Pt { int a; };
int fn(int);
template<class T> T tfn(T);
auto c1 = fn(1);
auto c2 = tfn<int>(1);
auto c3 = unknown_template<int>(1);
auto c4 = unknown_template<int>{1};
auto c5 = Pt{1}.a;
auto c6 = Pt().a;
