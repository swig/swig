%module char_enum_value

%inline %{

enum color { RED, BLUE, GREEN = 'g' };
enum escapes {
  NEWLINE = '\n',
  TAB = '\t',
  CAP_A = 'A',
};

%}
