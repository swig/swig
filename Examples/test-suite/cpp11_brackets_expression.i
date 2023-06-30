%module cpp11_brackets_expression

%warnfilter(SWIGWARN_PARSE_ASSIGNED_VALUE) Piece::kMaxSize;
%warnfilter(SWIGWARN_PARSE_ASSIGNED_VALUE) Piece::Just123;
%warnfilter(SWIGWARN_PARSE_ASSIGNED_VALUE) ::kMaxSizeGlobal;

%inline %{

#include <limits>

static constexpr int global_as_you_expect(int val) { return val; }
static constexpr int global_one_two_three() { return 123; }

class Piece {
public:
    typedef size_t size_type;
    typedef int difference_type;

    static constexpr size_type kOk2 = std::numeric_limits<difference_type>::max();

    // Failed to parse (issue #2640):
    static constexpr size_type kMaxSize = (std::numeric_limits<difference_type>::max)();

    // Also fails to parse:
//    int f(int x = (std::numeric_limits<difference_type>::max)());

    static constexpr size_type SimpleAsYouExpect123 = global_as_you_expect(123);
    static constexpr size_type SimpleJust123 = global_one_two_three();

    static constexpr size_type AsYouExpect123 = (global_as_you_expect)(123); // Did parse okay
    static constexpr size_type Just123 = (global_one_two_three)();           // Did not parse okay
};

static const Piece::size_type kMaxSizeGlobal = (std::numeric_limits<Piece::difference_type>::max)();
%}
