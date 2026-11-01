#include "register_par/register_par_wrap.h"

struct Tree {
  int flags;
};

int main(int argc, const char *argv[])
{
  /* The wrapper takes a pointer to this struct, as the header declares it outside the parameter list */
  struct Tree tree;
  register_par_clear_tree_flags(&tree, 0);
  return 0;
}
