%module std_containers

%include std_vector.i
%include std_string.i
%include std_deque.i
%include std_list.i
%include std_set.i
%include std_pair.i
%include std_map.i
%include std_complex.i


%template() std::vector< std::vector<double > > ;
%template(ccube) std::vector< std::vector< std::vector<double > > >;

%inline 
{ 
  typedef
    std::vector<std::vector<std::vector<double > > >
    ccube;
 
  ccube cident(const ccube& c)
  {
    return c;
  }
  
}


%template(map_si)  std::map<std::string, int>;
%template(set_i) std::set<int>;
%template(multiset_i) std::multiset<int>;
%template(list_i) std::list<int>;
%template(deque_i) std::deque<int>;

%template(vector_i) std::vector<int>;
%template(vector_c) std::vector<std::complex<double> >;
%template(vector_ui) std::vector<unsigned int>;

%template(imatrix) std::vector<std::vector<int> >;
%template(cmatrix) std::vector<std::vector<std::complex<double> > >;

%inline 
{
  typedef std::vector<std::vector<int> >  imatrix;
  imatrix mident(const imatrix& v)
  {
    return v;
  }

  std::map<int,int> mapidenti(const std::map<int,int>& v)
  {
    return v;
  }

  std::map<std::string,int> mapident(const std::map<std::string,int>& v)
  {
    return v;
  }

  std::vector<int> vident(const std::vector<int>& v)
  {
    return v;
  }

  std::set<int> sident(const std::set<int>& v)
  {
    return v;
  }

  std::vector<unsigned int> videntu(const std::vector<unsigned int>& v)
  {
    return v;
  }


  int get_elem(const std::vector<int>& v, int index)
  {
    return v[index];
  }

  std::pair<int,double> pident(const std::pair<int,double>& p) 
  {
    return p;
  }
  
  
}


%{
  
  template <class C> struct Param 
  {
  };	    
%}


template <class C> struct Param 
{
};


%template(Param_c) Param<std::complex<double> >;
%inline 
{
  int hello(Param<std::complex<double> > c)
  {
    return 0;
  }
}

%inline 
{
  struct A 
  {
  };  
}

%template() std::pair<A,int>;
%template(pair_iA) std::pair<int,A>;


%inline {
  std::pair<A,int> ident(std::pair<int,A> a, const std::pair<int,int>& b)
  {
    return std::pair<A,int>();
  }  
}

