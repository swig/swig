
/* ------------------------------------------------------------
 * The start of the PHP initialization function 
 * ------------------------------------------------------------ */

%insert(init) "swiginit.swg"

%init %{
  SWIG_php_minit {
    SWIG_InitializeModule(0);
    le_member_ptr = zend_register_list_destructors_ex(member_ptr_dtor, NULL, SWIG_MEMBER_PTR, module_number);
%}

