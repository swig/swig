%module xxx

struct Funcs {};

short (Funcs::* *)(bool) = 0;
short (Funcs::* const*)(bool) = 0;
