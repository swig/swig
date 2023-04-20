// Helper interface for cpp11_move_only.i and others

%include <std_string.i>
%catches(std::string) Counter::check_counts;

%inline %{
#include <sstream>
using namespace std;


struct Counter {
  static int normal_constructor;
  static int copy_constructor;
  static int copy_assignment;
  static int move_constructor;
  static int move_assignment;
  static int destructor;
  static void reset_counts() {
    normal_constructor = 0;
    copy_constructor = 0;
    copy_assignment = 0;
    move_constructor = 0;
    move_assignment = 0;
    destructor = 0;
  }
  // Check against expected counts of constructor, assignment operators etc.
  // Not observed during development, but compiler optimisation could change the expected values.
  // Throws exception if not correct (use %catches to catch them)
  static void check_counts(
      int normal_constructor,
      int copy_constructor,
      int copy_assignment,
      int move_constructor,
      int move_assignment,
      int destructor) {
    bool match = (
      normal_constructor == Counter::normal_constructor &&
      copy_constructor == Counter::copy_constructor &&
      copy_assignment == Counter::copy_assignment &&
      move_constructor == Counter::move_constructor &&
      move_assignment == Counter::move_assignment &&
      destructor == Counter::destructor);
    if (!match) {
      std::stringstream ss;
      ss << "check_counts failed" << std::endl <<
        Counter::normal_constructor << " " <<
        Counter::copy_constructor << " " <<
        Counter::copy_assignment << " " <<
        Counter::move_constructor << " " <<
        Counter::move_assignment << " " <<
        Counter::destructor << " " <<
        " (actual)" << std::endl <<
        normal_constructor << " " <<
        copy_constructor << " " <<
        copy_assignment << " " <<
        move_constructor << " " <<
        move_assignment << " " <<
        destructor << " " <<
        " (expected)" << std::endl;
      throw ss.str();
    }
  }
};

int Counter::normal_constructor = 0;
int Counter::copy_constructor = 0;
int Counter::copy_assignment = 0;
int Counter::move_constructor = 0;
int Counter::move_assignment = 0;
int Counter::destructor = 0;
%}
