%module("templatereduce") li_std_map

%include std_pair.i
%include std_map.i
%include std_multimap.i

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
  %template(pairAA) pair<int, A>;
  %template(pairA) pair<int, A*>;
  %template(mapA) map<int, A*>;
  %template(mmapA) multimap<int, A*>;

  %template(paircA1) pair<const int, A*>;
  %template(paircA2) pair<const int, const A*>;
  %template(pairiiA) pair<int,pair<int, A*> >;
  %template(pairiiAc) pair<int,const pair<int, A*> >;


  %template() pair<swig::PyObject_ptr, swig::PyObject_ptr>;
  %template(pymap) map<swig::PyObject_ptr, swig::PyObject_ptr>;
  
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




