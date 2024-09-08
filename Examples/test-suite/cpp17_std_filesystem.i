%module cpp17_std_filesystem

%include <std_string.i>
%include <std_filesystem.i>

%{
#include <filesystem>
%}

%inline %{
/* Test the "out" typemap for std::filesystem::path */
std::filesystem::path makePath(const std::string& s) {
    return std::filesystem::path(s);
}

/**
 * There is no "out" typemap for a pointer to a path, so
 * this should return a wrapped instance of a path
 * instead of the native path type for the target language.
 */
std::filesystem::path * makePathPtr(const std::string& s) {
    static std::filesystem::path p(s);
    return &p;
}

/**
 * There is no "out" typemap for a non-const reference to a path, so
 * this should return a wrapped instance of a std::filesystem::path instead of
 * the native path type for the target language.
 */
std::filesystem::path& makePathRef(const std::string& s) {
    static std::filesystem::path p(s);
    return p;
}

/**
 * There is no "out" typemap for a const reference to a path, so
 * this should return a wrapped instance of a std::filesystem::path
 * instead of the native path type for the target language.
 */
const std::filesystem::path & makePathConstRef(const std::string & s) {
    static std::filesystem::path p(s);
    return p;
}

/* Test the "in" typemap for std::filesystem::path */
std::string pathToStr(std::filesystem::path p) {
    return p.string();
}

/* Test the "in" typemap for const std::filesystem::path & */
std::string pathConstRefToStr(const std::filesystem::path & p) {
    return p.string();
}

/* Test the "in" typemap for const std::filesystem::path * */
std::string pathPtrToStr(const std::filesystem::path * p) {
    return p->string();
}

namespace stdfs = std::filesystem;
std::filesystem::path roundTrip(const stdfs::path& p) {
    return p;
}
%}
