%module xxx

/* Regression test for bug #368 introduced in 3.0.4 and fully fixed in 4.1.0.
 * The `%std` here led to SWIG calling abort() before 3.0.6, and was quietly
 * ignored in from 3.0.6 until 4.1.0.
 */
%typemap(jstype) std::vector<std::string>, const %std::vector<std::string>&, std::vector<std::string>&  "List<String>"
