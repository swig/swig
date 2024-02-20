%module xxx

struct BadDestructor1 {
    virtual ~BadDestructor1() = 1;
};

struct BadDestructor2 {
    ~BadDestructor2() = 0;
};

struct BadDestructor3 {
    ~BadDestructor3() const;
};
