#define IDLKW(x) %keywordwarn("'" `x` "' is a COM IDL keyword, renaming to '_" `x` "'", rename="_%s")  `x`

/*
 * This list may be incomplete. This is because most IDL keywords may be used as function/parameter
 * names, e.g. uuid, id, etc. Unfortunately this means that reserved names need to be found by
 * trial and error (and may be IDL compiler specific).
 */

IDLKW(coclass);
IDLKW(import);
IDLKW(importlib);
IDLKW(interface);
IDLKW(library);
IDLKW(module);

#undef IDLKW
