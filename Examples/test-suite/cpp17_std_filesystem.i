%module cpp17_std_filesystem

%include <std_string.i>
%include <std_filesystem.i>
%include <typemaps.i>

%apply int *OUTPUT { int *value };

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

/* Test the "out" typemaps with a path that is not valid UTF-8 where paths are narrow strings */
std::filesystem::path makeNonUtf8Path() {
    return std::filesystem::path("caf\xe9.txt");
}

const std::filesystem::path & makeNonUtf8PathConstRef() {
    static std::filesystem::path p("caf\xe9.txt");
    return p;
}

/* Test the "out" typemaps when an output parameter is appended to the result */
std::filesystem::path makePathAndValue(int *value) {
    *value = 1;
    return std::filesystem::path("foo");
}

const std::filesystem::path & makePathConstRefAndValue(int *value) {
    static std::filesystem::path p("foo");
    *value = 1;
    return p;
}

/* Test the "typecheck" typemaps */
const char * pathOrInt(std::filesystem::path) {
    return "path";
}

const char * pathOrInt(int) {
    return "int";
}

const char * pathConstRefOrInt(const std::filesystem::path &) {
    return "path";
}

const char * pathConstRefOrInt(int) {
    return "int";
}

const char * pathOrString(const std::filesystem::path &) {
    return "path";
}

const char * pathOrString(const std::string &) {
    return "string";
}
%}
