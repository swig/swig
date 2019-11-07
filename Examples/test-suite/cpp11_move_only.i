/* Check that C++11 move-only objects can be returned by value. */
%module cpp11_move_only

%inline %{
#include <utility>
%}


%inline %{
using std::swap;
class MoveOnly
{
private:
  int m_value;

public:
  MoveOnly &operator=(const MoveOnly &) = delete;
  MoveOnly(const MoveOnly &) = delete;

  MoveOnly(int v) : m_value(v) {}

  // move constructors which simulate leaving moved-from object in nonsense state.
  MoveOnly(MoveOnly &&that){*this = std::move(that);}
  MoveOnly& operator=(MoveOnly &&that){
    if (this != &that) {
      std::swap(m_value, that.m_value);
    }
    return *this;
  }

  int value() const {return m_value;}
};

// create move only object via factory function
// this still doesn't work:
// MoveOnly factory(int v) { return MoveOnly(v); }

%}