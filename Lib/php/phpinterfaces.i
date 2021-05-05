/* -----------------------------------------------------------------------------
 * phpinterfaces.i
 *
 * Define "known" PHP interfaces.
 *
 * These are accessible at MINIT time.  Any interface can be added via
 * phpinterfaces by looking up by name, but that has to wait until RINIT
 * time, which means it happens for every request.
 * ----------------------------------------------------------------------------- */

// Note: Abstract interfaces such as "Traversable" can't be used in
// "implements" so we don't include them here.

%fragment("zend_interfaces.h", "header") %{
#ifdef __cplusplus
extern "C" {
#endif
#include "zend_interfaces.h"
#ifdef __cplusplus
}
#endif
%}

%fragment("ext/spl/spl_iterators.h", "header") %{
#ifdef __cplusplus
extern "C" {
#endif
#include "ext/spl/spl_iterators.h"
#ifdef __cplusplus
}
#endif
%}

%fragment("ext/spl/spl_observer.h", "header") %{
#ifdef __cplusplus
extern "C" {
#endif
#include "ext/spl/spl_observer.h"
#ifdef __cplusplus
}
#endif
%}

%fragment("ext/date/php_date.h", "header") %{
#ifdef __cplusplus
extern "C" {
#endif
#include "ext/date/php_date.h"
#ifdef __cplusplus
}
#endif
%}

%fragment("ext/json/php_json.h", "header") %{
#ifdef __cplusplus
extern "C" {
#endif
#include "ext/json/php_json.h"
#ifdef __cplusplus
}
#endif
%}

%feature("phpinterface:Iterator", fragment="zend_interfaces.h") "zend_ce_iterator";
%feature("phpinterface:IteratorAggregate", fragment="zend_interfaces.h") "zend_ce_aggregate";
%feature("phpinterface:ArrayAccess", fragment="zend_interfaces.h") "zend_ce_arrayaccess";
%feature("phpinterface:Serializable", fragment="zend_interfaces.h") "zend_ce_serializable";
%feature("phpinterface:Countable", fragment="zend_interfaces.h") "zend_ce_countable";
%feature("phpinterface:OuterIterator", fragment="ext/spl/spl_iterators.h") "spl_ce_OuterIterator";
%feature("phpinterface:RecursiveIterator", fragment="ext/spl/spl_iterators.h") "spl_ce_RecursiveIterator";
%feature("phpinterface:SeekableIterator", fragment="ext/spl/spl_iterators.h") "spl_ce_SeekableIterator";
%feature("phpinterface:SplObserver", fragment="ext/spl/spl_observer.h") "spl_ce_SplObserver";
%feature("phpinterface:SplSubject", fragment="ext/spl/spl_observer.h") "spl_ce_SplSubject";
%feature("phpinterface:DateTimeInterface", fragment="ext/date/php_date.h") "php_date_get_interface_ce()";
// The "json" extension needs to be loaded earlier that us for this to work.
%feature("phpinterface:JsonSerializable", fragment="ext/json/php_json.h") "php_json_serializable_ce";

// New in PHP 8.0.
%feature("phpinterface:Stringable", fragment="zend_interfaces.h") "zend_ce_stringable";
