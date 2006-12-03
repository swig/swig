%module keywords

// fix up conflicts with C++ keywords
%rename("and") Keywords::and_;
%rename("break") Keywords::break_;
%rename("case") Keywords::case_;
%rename("class") Keywords::class_;
%rename("defined?") Keywords::defined_;
%rename("do") Keywords::do_;
%rename("else") Keywords::else_;
%rename("false") Keywords::false_;
%rename("for") Keywords::for_;
%rename("if") Keywords::if_;
%rename("not") Keywords::not_;
%rename("return") Keywords::return_;
%rename("or") Keywords::or_;
%rename("true") Keywords::true_;
%rename("while") Keywords::while_;


%inline %{

class Keywords {
public:
	Keywords() {}

	char* alias() { return "alias"; }
  char* and_() { return "and"; }
  char* begin() { return "begin"; }
  char* break_() { return "break"; }
  char* case_() { return "case"; }
  char* class_() { return "class"; }
  char* def() { return "def"; }
  char* defined_() { return "defined?"; }
  char* do_() { return "do"; }
  char* else_() { return "else"; }
  char* elsif() { return "elsif"; }
  char* end() { return "end"; }
	char* ensure() { return "ensure"; }
  char* false_() { return "false"; }
  char* for_() { return "for"; }
  char* if_() { return "if"; }
	char* in() { return "in"; }
  char* module() { return "module"; }
  char* next() { return "next"; }
  char* nil() { return "nil"; }
  char* not_() { return "not"; }
  char* or_() { return "or"; }
  char* redo() { return "redo"; }
  char* rescue() { return "rescue"; }
  char* retry() { return "retry"; }
  char* return_() { return "return"; }
  char* self() { return "self"; }
  char* super() { return "super"; }
  char* then() { return "then"; }
  char* true_() { return "true"; }
  char* undef() { return "undef"; }
  char* under() { return "under"; }
  char* unless() { return "unless"; }
	char* until() { return "until"; }
  char* when() { return "when"; }
  char* while_() { return "while"; }
  char* yield() { return "yield"; }
};
%}
