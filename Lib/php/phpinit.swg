
/* ------------------------------------------------------------
 * The start of the PHP initialization function 
 * ------------------------------------------------------------ */

%insert(init) "swiginit.swg"

%init %{
  SWIG_php_minit {
    SWIG_InitializeModule(0);
%}

%fragment("swig_php_init_member_ptr2", "header") {
#define SWIG_MEMBER_PTR ((char*)"CLASS::*")

static void member_ptr_dtor(zend_rsrc_list_entry *rsrc TSRMLS_DC) {
  efree(rsrc->ptr);
}

static int le_member_ptr;
}

%fragment("swig_php_init_member_ptr", "init", fragment="swig_php_init_member_ptr2") {
    le_member_ptr = zend_register_list_destructors_ex(member_ptr_dtor, NULL, SWIG_MEMBER_PTR, module_number);
}
