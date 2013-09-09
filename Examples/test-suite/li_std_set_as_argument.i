%module li_std_set_as_argument

%{
#include <set>
#include <string>

#include <iostream>
#include <iterator>
#include <algorithm>
#include <numeric>
#include <sstream>

%}

%include stl.i

namespace std
{
    %template(IntSet) set<int>;
    %template(StringSet) set<std::string>;
}

%ignore concat_set;

%inline %{
template <typename T>
std::set<T> concat_set(const std::set<T> set, const std::set<T> other_set)
{
    std::set<T> out_set(set);
    out_set.insert(other_set.begin(), other_set.end());
    return out_set;
}

// int sets

std::set<int> create_integer_set(const int rangemin, const int rangemax)
{
    std::set<int> out_set;
    for (int i = rangemin; i <= rangemax; i++)
    {
        out_set.insert(i);
    }
    return out_set;
}

int sum_integer_set(const std::set<int>& set)
{
    return std::accumulate(set.begin(), set.end(), 0);
}

std::set<int> concat_integer_set(const std::set<int> set, const std::set<int> other_set)
{
    return concat_set<int>(set, other_set);
}

// string sets

std::set<std::string> create_string_set(const char* svalue)
{
    std::set<std::string> out_set;
    std::string str(svalue);

    std::istringstream iss(str);
    std::copy(std::istream_iterator<std::string>(iss),
        std::istream_iterator<std::string>(),
        std::inserter<std::set<std::string> >(out_set, out_set.begin()));

    return out_set;
}

std::set<std::string> concat_string_set(const std::set<std::string> set, const std::set<std::string> other_set)
{
    return concat_set<std::string>(set, other_set);
}
%}

