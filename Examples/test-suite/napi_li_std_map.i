// Node-API specific implementations
// (with copy-conversion)
%module napi_li_std_map

/* --- std::map --- */
%include "std_map.i"

// for valueAverage & stringifyKeys
%apply(std::map INPUT)               { std::map m };

// for populate
%apply(std::map &OUTPUT)             { std::map &m };

%include "li_std_map.i"
