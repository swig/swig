%module std_containers

%include std_vector.i
%include std_string.i
%include std_deque.i
%include std_list.i
%include std_set.i
%include std_multiset.i
%include std_pair.i
%include std_map.i
%include std_multimap.i
%include std_complex.i

#ifndef SWIG_STD_DEFAULT_INSTANTIATION
%template() std::vector<double>;
%template() std::pair<std::string, int>;
%template() std::pair<int,double>;
#endif

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
%template(mmap_si)  std::multimap<std::string, int>;
%template(set_i) std::set<int>;
%template(multiset_i) std::multiset<int>;
%template(list_i) std::list<int>;
%template(deque_i) std::deque<int>;

%template(vector_i) std::vector<int>;
%template(vector_c) std::vector<std::complex<double> >;
%template(vector_ui) std::vector<unsigned int>;

%template(imatrix) std::vector<std::vector<int> >;
%template(cmatrix) std::vector<std::vector<std::complex<double> > >;

%apply std::vector<int> *INOUT {std::vector<int> *INOUT2};

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

  std::multimap<std::string,int> mapident(const std::multimap<std::string,int>& v)
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

  void
  v_inout(std::vector<int> *INOUT) {
    *INOUT = *INOUT;
  }  

  void
  v_inout2(std::vector<int> *INOUT, std::vector<int> *INOUT2) {
    std::swap(*INOUT, *INOUT2);
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
    A(int aa = 0) : a(aa)
    {
    }
    int a;
  };  
}

%template() std::pair<A,int>;
%template(pair_iA) std::pair<int,A>;
%template(vector_piA) std::vector<std::pair<int,A> >;


%inline {
  std::pair<A,int> ident(std::pair<int,A> a, const std::pair<int,int>& b)
  {
    return std::pair<A,int>();
  }  


  std::vector<std::pair<int,A> > pia_vident(std::vector<std::pair<int,A> > a )
  {
    return a;
  }  

  struct Foo
  {
    Foo(int i) {
    }
  };
  
}


%std_nodefconst_type(Foo);

%template(vector_Foo) std::vector<Foo>;
%template(deque_Foo) std::deque<Foo>;
%template(list_Foo) std::list<Foo>;


