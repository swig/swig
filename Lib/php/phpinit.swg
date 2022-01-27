
/* ------------------------------------------------------------
 * The start of the PHP initialization function
 * ------------------------------------------------------------ */

%insert(init) "swiginit.swg"

%init %{
SWIG_php_minit {
  zend_class_entry SWIGUNUSED internal_ce;
  SWIG_InitializeModule((void*)&module_number);
%}
