%module li_std_vector_vector

%include <std_string.i>
%include <std_vector.i>

namespace std {
  %template(VectorInt)   vector<int>;
  %template(VectorString)   vector<string>;
  %template(VectorVectorInt)   vector<vector<int>>;
  %template(VectorVectorString)   vector<vector<string>>;
};

%inline %{
std::vector<std::string> make_vector_int() {
    std::vector<std::string> v = {"1", "2", "3", "4", "5"};
    return v;
}

std::vector<std::vector<int> > make_vector_vector_int() {
    std::vector<std::vector<int> > vv;
    std::vector<int> v = {1, 2, 3, 4, 5};
    vv.push_back(v);
    return vv;
}

std::vector<bool> make_vector_bool() {
    std::vector<bool> v = {true, false, false, false, true};
    return v;
}

std::vector<std::vector<bool> > make_vector_vector_bool() {
    std::vector<std::vector<bool> > vv;
    std::vector<bool> v = {false, true, true, true, false};
    vv.push_back(v);
    return vv;
}

std::vector<std::string> make_vector_string() {
    std::vector<std::string> v = {"aa", "bb", "cc", "dd", "ee"};
    return v;
}

std::vector<std::vector<std::string> > make_vector_vector_string() {
    std::vector<std::vector<std::string> > vv;
    std::vector<std::string> v = {"1", "2", "3", "4", "5"};
    vv.push_back(v);
    return vv;
}

%}
