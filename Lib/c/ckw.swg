#ifndef C_CKW_SWG_
#define C_CKW_SWG_

/* Warnings for C++ keywords, which can name neither the C++ wrappers nor the C declarations, as the header is also compiled as C++ */
#define CXXKW(x) %keywordwarn("'" `x` "' is a C++ keyword",rename="c_%s")  `x`

/* Only for C++ code, where only a directive such as %rename or %constant can give such a name: C code can use C++ keywords as names */
#ifdef __cplusplus

/* The keywords and alternative tokens of C++23, from [lex.key] and [lex.digraph] of the standard */

CXXKW(alignas);
CXXKW(alignof);
CXXKW(and);
CXXKW(and_eq);
CXXKW(asm);
CXXKW(auto);
CXXKW(bitand);
CXXKW(bitor);
CXXKW(bool);
CXXKW(break);
CXXKW(case);
CXXKW(catch);
CXXKW(char);
CXXKW(char8_t);
CXXKW(char16_t);
CXXKW(char32_t);
CXXKW(class);
CXXKW(compl);
CXXKW(concept);
CXXKW(const);
CXXKW(consteval);
CXXKW(constexpr);
CXXKW(constinit);
CXXKW(const_cast);
CXXKW(continue);
CXXKW(co_await);
CXXKW(co_return);
CXXKW(co_yield);
CXXKW(decltype);
CXXKW(default);
CXXKW(delete);
CXXKW(do);
CXXKW(double);
CXXKW(dynamic_cast);
CXXKW(else);
CXXKW(enum);
CXXKW(explicit);
CXXKW(export);
CXXKW(extern);
CXXKW(false);
CXXKW(float);
CXXKW(for);
CXXKW(friend);
CXXKW(goto);
CXXKW(if);
CXXKW(inline);
CXXKW(int);
CXXKW(long);
CXXKW(mutable);
CXXKW(namespace);
CXXKW(new);
CXXKW(noexcept);
CXXKW(not);
CXXKW(not_eq);
CXXKW(nullptr);
CXXKW(operator);
CXXKW(or);
CXXKW(or_eq);
CXXKW(private);
CXXKW(protected);
CXXKW(public);
CXXKW(register);
CXXKW(reinterpret_cast);
CXXKW(requires);
CXXKW(return);
CXXKW(short);
CXXKW(signed);
CXXKW(sizeof);
CXXKW(static);
CXXKW(static_assert);
CXXKW(static_cast);
CXXKW(struct);
CXXKW(switch);
CXXKW(template);
CXXKW(this);
CXXKW(thread_local);
CXXKW(throw);
CXXKW(true);
CXXKW(try);
CXXKW(typedef);
CXXKW(typeid);
CXXKW(typename);
CXXKW(union);
CXXKW(unsigned);
CXXKW(using);
CXXKW(virtual);
CXXKW(void);
CXXKW(volatile);
CXXKW(wchar_t);
CXXKW(while);
CXXKW(xor);
CXXKW(xor_eq);

#endif // __cplusplus

#undef CXXKW

#endif //C_CKW_SWG_
