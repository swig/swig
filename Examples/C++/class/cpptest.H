// Copyright (C) 2000 Tal Shalif

class cpptest_base
{
  MyString str;
public:
  cpptest_base(const MyString &s) : str(s) {}
  const MyString &get() const {return str;}
  void set(const MyString &s) {str = s;}
};

class cpptest_empty
{
public:
  cpptest_empty() {}
};

class cpptest : public cpptest_base
{
  MyString str;
  cpptest_base base;
public:
  cpptest(const MyString &s) : cpptest_base(s), base(s) {}
  int getInt() const {return 1;}
  const char *getString() const {return "string";}
  const char *getMyString(const MyString &s) const {return s.c_str();}
  cpptest &getObject() {return *this;}
  cpptest &getObject2(const char *s) {return *this;}
  cpptest &getObject3(const MyString &s) {return *this;}
  cpptest_base &outBaseClass() {return *this;}
  const MyString &inBaseClass(const cpptest_base &e) {return e.get();}
};

// cpptest.H ends here
