%import "multi_import_d.i"

// NB: this module is only imported, never compiled, so it's not necessary to
// include the header for testing purposes.

class XXX
{
public:
  int testx();
};
