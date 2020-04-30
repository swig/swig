/* File : example.h */

#include <iostream>

class Interface {
	unsigned long c_;
public:
	virtual unsigned long AddRef() {
		c_ += 1;
		return c_;
	}
	virtual unsigned long Release() {
		c_ -= 1;
		return c_;
	}
};

class Callback : public Interface {
public:
	virtual ~Callback() { std::cout << "Callback::~Callback()" << std:: endl; }
	virtual void run() { std::cout << "Callback::run()" << std::endl; }
};


class Caller : public Interface {
private:
	Callback *_callback;
public:
	Caller(): _callback(0) {}
	~Caller() { delCallback(); }
	void delCallback() { delete _callback; _callback = 0; }
	void setCallback(Callback *cb) { delCallback(); _callback = cb; }
	void call() { if (_callback) _callback->run(); }
};

