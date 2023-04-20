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
    std::string x[5] = {"1", "2", "3", "4", "5"};
    std::vector<std::string> v;
    for (size_t i = 0; i < 5; ++i)
      v.push_back(x[i]);
    return v;
}

std::vector<std::vector<int> > make_vector_vector_int() {
    int x[5] = {1, 2, 3, 4, 5};
    std::vector<std::vector<int> > vv;
    std::vector<int> v;
    for (size_t i = 0; i < 5; ++i)
      v.push_back(x[i]);
    vv.push_back(v);
    return vv;
}

std::vector<bool> make_vector_bool() {
    bool x[5] = {true, false, false, false, true};
    std::vector<bool> v;
    for (size_t i = 0; i < 5; ++i)
      v.push_back(x[i]);
    return v;
}

std::vector<std::vector<bool> > make_vector_vector_bool() {
    bool x[5] = {false, true, true, true, false};
    std::vector<std::vector<bool> > vv;
    std::vector<bool> v;
    for (size_t i = 0; i < 5; ++i)
      v.push_back(x[i]);
    vv.push_back(v);
    return vv;
}

std::vector<std::string> make_vector_string() {
    std::string x[5] = {"aa", "bb", "cc", "dd", "ee"};
    std::vector<std::string> v;
    for (size_t i = 0; i < 5; ++i)
      v.push_back(x[i]);
    return v;
}

std::vector<std::vector<std::string> > make_vector_vector_string() {
    std::string x[5] = {"1", "2", "3", "4", "5"};
    std::vector<std::vector<std::string> > vv;
    std::vector<std::string> v;
    for (size_t i = 0; i < 5; ++i)
      v.push_back(x[i]);
    vv.push_back(v);
    return vv;
}

%}
