#include <libguile.h>

extern "C" {

  SCM scm_init_a_module();
  SCM scm_init_b_module();
  
  static void
  inner_main(void *closure, int argc, char **argv)
  {
    scm_init_a_module();
    scm_init_b_module();
    scm_shell(argc, argv);	/* scheme interpreter */
    /* never reached: scm_shell will perform an exit */
  }

}

int
main(int argc, char **argv)
{
  scm_boot_guile(argc, argv, inner_main, 0); 
  return 0;
}
