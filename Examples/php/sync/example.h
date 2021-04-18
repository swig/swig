#include <string>

extern std::string s;
extern int x;

class Sync {
  public:
    int x;
    std::string s;
    void printer();
    void all_change();

    Sync() : x(0) { }
};
