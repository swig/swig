/* Rename keywords.  */

#define GOKW(x) %keywordwarn("'" `x` "' is a Go keyword, renaming to 'X"`x`"'",rename="X%s")  `x`

GOKW(break);
GOKW(case);
GOKW(chan);
GOKW(const);
GOKW(continue);
GOKW(default);
GOKW(defer);
GOKW(else);
GOKW(fallthrough);
GOKW(for);
GOKW(func);
GOKW(go);
GOKW(goto);
GOKW(if);
GOKW(import);
GOKW(interface);
GOKW(map);
GOKW(package);
GOKW(range);
GOKW(return);
GOKW(select);
GOKW(struct);
GOKW(switch);
GOKW(type);
GOKW(var);

#undef GOKW
