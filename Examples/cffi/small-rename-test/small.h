
#if 0
int func (double onlyarg);
int Func (double onlyarg);
int FUNC (double onlyarg);

class testclass { public: int cppmethod(); 
  int cppmethod(int a); 
};
class TestClass { public: int CppMethod(); 
  int CppMethod(int a); 
};
class TESTCLASS { public: int CPPMETHOD(); 
  int CPPMETHOD(int a); 
};

#endif 

class TESTCLASS { public: 
  int planet(int a);

  int oldme();
  int oldme(int a); 
  int oldme(double a); 

  int oldme(int a, int b); 
  int oldme(int a, double b); 

  int brother();
  int from_another();
  
};
