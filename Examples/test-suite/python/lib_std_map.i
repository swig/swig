%module lib_std_map

//#define SWIG_STD_EXTEND_COMPARISON
///
%include std_pair.i
%include std_map.i

%inline %{
struct A{
    int val;
    
    A(int v = 0): val(v)
    {
    }

};
%}

namespace std
{
  %template(pairii) pair<int, int>;
  %template(pairA) pair<int, A*>;
  %template(mapA) map<int, A*>;
}



%inline 
{
std::pair<int, A*> 
p_identa(std::pair<int, A*> p) {
  return p;
}

std::map<int,A*> m_identa(const std::map<int,A*>& v)
{
  return v;
}

}




