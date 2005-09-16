/* File : example.i */
%module example

%init{
  zend_printf("This was %%init\n");
}

%minit{
  zend_printf("This was %%minit\n");
}

%mshutdown{
  zend_printf("This was %%shutdown\n");
}

%rinit{
  zend_printf("This was %%rinit\n");
}

%rshutdown{
  zend_printf("This was %%rshutdown\n");
}

%pragma(php4) include="hi.php";

%pragma(php4) code="
# This code is inserted into example.php
echo \"this was php4 code\\n\";
"

%pragma(php4) phpinfo="php_info_print_table_start();"
