/* File : callback.h */
#include <string>

// Callback typedef: should take a string and return a new one
typedef std::string (*fp_transform)(const std::string& str);

std::string passthrough(const std::string& s);
std::string enquote(const std::string& s);

// Join a bunch of strings with the given callback
std::string join_transformed(const std::string& joiner, fp_transform cb);

/* vim: set ts=2 sw=2 sts=2 tw=129 : */
