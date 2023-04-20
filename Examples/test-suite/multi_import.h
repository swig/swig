#ifndef MULTI_IMPORT_H
#define MULTI_IMPORT_H

class WWW {
  public:
    void nullop() const {}
};

class XXX
{
	public:
		int testx() { return 0;}
};

class YYY : public XXX
{
	public:
		int testy() { return 1;}
};

class ZZZ : public XXX
{
	public:
		int testz() { return 2;}
};

#endif /* MULTI_IMPORT_H */
