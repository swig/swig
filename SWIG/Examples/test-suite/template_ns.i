// Tests the use of the %template directive with fully
// qualified scope names

%module template_ns

%warnfilter(801) std::pair<int, int>;       /* Ruby, wrong class name */
%warnfilter(801) std::pair<double, double>; /* Ruby, wrong class name */

%ignore std::pair::pair();

%inline %{
namespace std
{
template <class _T1, class _T2>
struct pair {
  typedef _T1 first_type; 
  typedef _T2 second_type;

  _T1 first;              
  _T2 second;             
  pair() : first(_T1()), second(_T2()) {}
  pair(const _T1& __a, const _T2& __b) : first(__a), second(__b) {}
  template <class _U1, class _U2>
  pair(const pair<_U1, _U2>& __p) : first(__p.first), second(__p.second) {}
};
}
%}

// Add copy constructor
%extend std::pair {
   %template(pair) pair<_T1,_T2>;
};

%template(pairii) std::pair<int,int>;
%template(pairdd) std::pair<double,double>;
