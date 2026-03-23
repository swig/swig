/* Test std_function support for Lua */
%module(directors="1") lua_std_function

%include <std_string.i>
%include <std_function.i>

/* Define various std::function types for testing */
%std_function(VoidCallback, void)
%std_function(IntCallback, int, int)
%std_function(StringCallback, std::string, const std::string &)
%std_function(BoolCallback, bool, bool)
%std_function(DoubleCallback, double, double)
%std_function(MultiArgCallback, double, int, double, const std::string &)
%std_function(VoidIntCallback, void, int)

%inline %{

#include <functional>
#include <string>
#include <vector>

/* ------- Simple callback functions (by value) ------- */

int callIntCallback(std::function<int(int)> cb, int value) {
    return cb(value);
}

void callVoidCallback(std::function<void()> cb) {
    cb();
}

std::string callStringCallback(
    std::function<std::string(const std::string &)> cb,
    const std::string &value) {
    return cb(value);
}

bool callBoolCallback(std::function<bool(bool)> cb, bool value) {
    return cb(value);
}

double callDoubleCallback(std::function<double(double)> cb, double value) {
    return cb(value);
}

double callMultiArgCallback(
    std::function<double(int, double, const std::string &)> cb,
    int a, double b, const std::string &c) {
    return cb(a, b, c);
}

/* ------- Callback by const reference ------- */

int callIntCallbackConstRef(const std::function<int(int)> &cb, int value) {
    return cb(value);
}

/* ------- Callback by rvalue reference (move) ------- */

int callIntCallbackRvalueRef(std::function<int(int)> &&cb, int value) {
    std::function<int(int)> local_cb = std::move(cb);
    return local_cb(value);
}

/* ------- Callback via pointer (nullable) ------- */

int callIntCallbackPtr(std::function<int(int)> *cb, int value) {
    if (cb) return (*cb)(value);
    return -1;
}

/* ------- Class that stores a callback ------- */

class CallbackHolder {
public:
    void setCallback(std::function<int(int)> cb) {
        callback_ = cb;
    }

    void setCallbackConstRef(const std::function<int(int)> &cb) {
        callback_ = cb;
    }

    void setCallbackRvalue(std::function<int(int)> &&cb) {
        callback_ = std::move(cb);
    }

    int callCallback(int value) const {
        if (callback_) return callback_(value);
        return -1;
    }

    bool hasCallback() const {
        return static_cast<bool>(callback_);
    }

private:
    std::function<int(int)> callback_;
};

/* ------- Function that returns a std::function ------- */

std::function<int(int)> makeDoubler() {
    return [](int x) { return x * 2; };
}

std::function<int(int)> makeAdder(int n) {
    return [n](int x) { return x + n; };
}

/* ------- Side-effect tracking for void callbacks ------- */

static int g_void_callback_counter = 0;

void callVoidIntCallback(std::function<void(int)> cb, int value) {
    cb(value);
}

int getVoidCallbackCounter() {
    return g_void_callback_counter;
}

void resetVoidCallbackCounter() {
    g_void_callback_counter = 0;
}

void incrementVoidCallbackCounter() {
    g_void_callback_counter++;
}

/* ------- Multiple callbacks in a single call ------- */

int callTwoCallbacks(std::function<int(int)> cb1, std::function<int(int)> cb2, int value) {
    return cb1(value) + cb2(value);
}

%}
