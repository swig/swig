/* File : example.h */

#include <cstdio>
#include <iostream>

class Callback {
public:
	virtual ~Callback() { std::cout << "Callback::~Callback()" << std:: endl; }
    virtual void run() { std::cout << "Callback::~Callback()" << std:: endl;}
};

class CCallback : public Callback {
public:
    virtual ~CCallback() { std::cout << "CCallback::~Callback()" << std:: endl; }
    virtual void run() { std::cout << "CCallback::~Callback()" << std:: endl;}
    virtual void run2() { std::cout << "CCallback::~Callback()" << std:: endl;}
};



class Caller {
private:
    Callback *_callback;
public:
	Caller(): _callback(0) {}
	~Caller() { delCallback(); }
	void delCallback() { delete _callback; _callback = 0; }
	void setCallback(Callback *cb) { delCallback(); _callback = cb; }
	void call() { if (_callback) _callback->run(); }
};



class Caller2: public Caller{
private:
    CCallback *_callback;
public:
    void delCallback() { delete _callback; _callback = 0; }
    void setCallback(CCallback *cb) { delCallback(); _callback = cb; }
};


