static char cvs[] = "$Header$";

extern "C" void tclwadinit();

/* This hack is used to auto-initialize wad regardless of whether we are
   used as an imported module or as a link-library for another module */
   
class wadinitializer {
public:
  wadinitializer() {
    tclwadinit();
  }
};

static wadinitializer wi;
