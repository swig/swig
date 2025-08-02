%module friends
%{
#include <iostream>
%}

%warnfilter(SWIGWARN_LANG_IDENTIFIER) operator<<;
%warnfilter(SWIGWARN_LANG_IDENTIFIER) operator>>;

#if defined(SWIGOCTAVE)
%warnfilter(SWIGWARN_IGNORE_OPERATOR_LSHIFT) operator<<;
%warnfilter(SWIGWARN_IGNORE_OPERATOR_RSHIFT) operator>>;
#endif


%inline 
{

  void globalscope(); // forward declaration needed for some compilers

  struct A;
  struct B
  {
    B(int i) : v(i) 
    {
    }
    
    friend void ::globalscope();
    friend int mix(A* a, B *b);
    virtual ~B()
    {
    }
    
  private:
    int v;
    
  };
  
  void globalscope() { B b(0); b.v=10; }
  
  struct A
  {
    A(int v) : val(v)
    {
    }

    friend int get_val1(const A& a)
    {
      return a.val;
    }

    /* simple overloading */
    friend int get_val1(const A& a, int o)
    {
      return a.val + o;
    }

    /*
      note that operators << and >> are ignored, as they
      should, since no rename is performed.
    */
    friend std::istream& operator>>(std::istream& in, A& a);

    /* already declare at B */
    friend int mix(A* a, B *b);

  protected:
    friend int get_val2(const A& a)
    {
      return a.val*2;
    }
    
  private:
    friend int get_val3(const A& a);

    /* this should be ignored */
    friend std::ostream& operator<<(std::ostream& out, const A& a)
    {
      out << a.val;
      return out;
    }

    int val;    
  };

  /* 
     'mix' is an interesting case, this is the third declaration
     swig is getting (two friends + one inline).
   */
  inline int mix(A* a, B *b) {
    return a->val + b->v;
  }

  /* this should be ignored */
  inline std::istream& operator>>(std::istream& in, A& a) {
    int v;
    in >> v;
    a = A(v);
    return in;
  }

  inline int get_val3(const A& a) {
    return a.val*3;
  }
  
  /* another overloading */
  inline int get_val1(int i, int a, int b) {
    return i;
  }


  /*
    sit and watch how well this case works, is just incredible!!,

    also note that there is no special code added to manage friends
    and templates (or overloading), this is just old swig magic
    working at its best.
  */

  template <class C>
    struct D
    {
      D(C v) : val(v) {}

      /* note that here we are overloading the already super
	 overloaded 'get_val1' */
      friend C get_val1(D& b)
      {
	return b.val;
      }

      /* here set will be 'auto' overloaded, depending of the
	 %template instantiations. */
      friend void set(D& b, C v)
      {
	b.val = v;
      }

    private:
      C val;
    };

  namespace ns1 {
    void bas() {}
    void baz() {}
  }
}

%inline %{
  class CModelParameterSpecies;
  class CModelParameterCompartment {
    CModelParameterSpecies *species;
  public:
    int getSpeciesVal();
    CModelParameterCompartment();
    ~CModelParameterCompartment();
  };
  class CModelParameterSpecies
  {
    int private_val;
  public:
    // Friend function-declarations are silently ignored (including constructor and destructor declarations)
    friend CModelParameterCompartment::~CModelParameterCompartment();
    friend CModelParameterCompartment::CModelParameterCompartment();
    friend int CModelParameterCompartment::getSpeciesVal();
  };
%}

%{
CModelParameterCompartment::CModelParameterCompartment() {
  species = new CModelParameterSpecies();
  species->private_val = 1;
}
CModelParameterCompartment::~CModelParameterCompartment() {
  species->private_val = 0;
  delete species;
}
int CModelParameterCompartment::getSpeciesVal() {
  return species->private_val;
}
%}


// Unqualified friend function definition and declaration example from SWIG docs
%inline %{
class Chum {
  int val;
  friend int chum_blah() { Chum c; c.private_function(); return c.val; }
  void private_function();
};

class Mate {
  int val;
  friend int mate_blah(); // Unqualified friend function declaration
  void private_function();
};
%}

%{
// Only seen by the compiler, not seen by SWIG
int chum_blah();
int mate_blah() { Mate m; m.private_function(); return m.val; }

void Chum::private_function() { this->val = 1234; }
void Mate::private_function() { this->val = 4321; }
%}


// Foe class tests friend definitions/declarations in a namespace
%inline %{
  namespace ns1 {
    namespace ns2 {
      class Foe {
        int val;
      public:
	Foe() : val() {}
	Foe(int val) : val(val) {}
        // Unqualified friends visible to SWIG in outer scope
	friend int friend_definition() { return Foe(10).val; }
	friend int friend_declaration();
	friend int friend_args_definition(Foe &foe) { return foe.val; }
	friend int friend_args_declaration(Foe &foe);

        // Unqualified friends only visible to C++ compiler in outer scope
	friend int friend_definition_compiler() { return Foe(20).val; }
	friend int friend_declaration_compiler();
	friend int friend_args_definition_compiler(Foe &foe) { return foe.val; }
	friend int friend_args_declaration_compiler(Foe &foe);

        // Qualified friend (silently ignored)
	friend void ns1::baz();
      };
      int friend_definition();
      int friend_declaration() { return Foe(11).val; }
      int friend_args_definition(Foe &foe);
      int friend_args_declaration(Foe &foe) { return foe.val; }
    }
  }
%}

%{
  namespace ns1 {
    namespace ns2 {
      int friend_definition_compiler();
      int friend_declaration_compiler() { return Foe(21).val; }
   // int friend_args_definition_compiler(Foe &foe); // ADL is used to find this, so no declaration is needed
      int friend_args_declaration_compiler(Foe &foe) { return foe.val; }
    }
  }
%}


%template(D_i) D<int>;
%template(D_d) D<double>;
