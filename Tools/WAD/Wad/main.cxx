extern "C" {
#include "wad.h"
}

/* This is a sick hack to force initialization upon loading */

class StartDebug {
public:
  StartDebug() {
    wad_init();
  }
};

static StartDebug s;
