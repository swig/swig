%module duplicate_parm_names

// Testing duplicate argument name handling

%{
void fn_2parms(int, int) {}
void fn_3parms(int, int, double) {}
void fn_4parms(int, short, double, const char *) {}

struct SameParmNameCheck {
  void metho(int, short, double, const char *) {}
};
%}

void fn_2parms(int argx, int argx) {}
void fn_3parms(int p_a, int p_a, double p_c) {}
void fn_4parms(int duplicate, short duplicate, double duplicate, const char *duplicate) {}

struct SameParmNameCheck {
  void metho(int dup, short dup, double uniq, const char *dup) {}
};
