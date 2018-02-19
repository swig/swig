/* -------------------------------------------------------------------------
 * forkw.swg
 * ------------------------------------------------------------------------- */

#ifdef __cplusplus
// Give special names to special operations
//%rename(__ptr__)    *::operator->;
//%rename(__deref__)  *::operator*();
//%ignore *::operator*() const;
//%rename(__assign__) *::operator=;
//%rename(__eq__) *::operator==;
%ignore *::operator->;
%ignore *::operator*();
%ignore *::operator=;

// Add suffix
%keywordwarn("'release' is reserved for SWIG destructors",
             rename="release_") "*::release";
%keywordwarn("'final' is reserved for SWIG finalization routines",
             rename="final_") "*::release";
#endif

// Prevent identifiers from having a leading underscore.
// Since SWIG uses "__dummy_%d__" internally for %template()-instantiated
// classes, ignore identifiers that also end with _.
%namewarn("Fortran identifiers may not begin with underscores or numerals; "
          "prepending 'f' to %s",
          rename="f%s", regextarget=1) "^[_0-9]+.*[^_]+$";

#define FORTRANKW(x) %keywordwarn("'" `x` "' is a Fortran keyword")  `x`

#define FORTRANFN(x) %keywordwarn("'" `x` "' is a Fortran built-in function" `x` "'",sourcefmt="%(lower)s",%$isfunction,%$not %$ismember) `x`


// FORTRAN 77
//FORTRANKW(assign);
FORTRANKW(backspace);
FORTRANKW(block data);
FORTRANKW(call);
FORTRANKW(close);
FORTRANKW(common);
FORTRANKW(continue);
FORTRANKW(data);
FORTRANKW(dimension);
FORTRANKW(do);
FORTRANKW(else);
FORTRANKW(else if);
FORTRANKW(end);
FORTRANKW(endfile);
FORTRANKW(endif);
//FORTRANKW(entry);
FORTRANKW(equivalence);
FORTRANKW(external);
FORTRANKW(format);
FORTRANKW(function);
FORTRANKW(goto);
FORTRANKW(if);
FORTRANKW(implicit);
FORTRANKW(inquire);
FORTRANKW(intrinsic);
FORTRANKW(open);
FORTRANKW(parameter);
//FORTRANKW(pause);
FORTRANKW(print);
FORTRANKW(program);
FORTRANKW(read);
FORTRANKW(return);
FORTRANKW(rewind);
FORTRANKW(rewrite);
FORTRANKW(save);
FORTRANKW(stop);
FORTRANKW(subroutine);
FORTRANKW(then);
FORTRANKW(write);

// Fortran 90
// FORTRANKW(allocatable);
// FORTRANKW(allocate);
// FORTRANKW(case);
// FORTRANKW(contains);
// FORTRANKW(cycle);
// FORTRANKW(deallocate);
// FORTRANKW(elsewhere);
// FORTRANKW(exit);
// FORTRANKW(include);
// FORTRANKW(interface);
// FORTRANKW(intent);
// FORTRANKW(module);
// FORTRANKW(namelist);
// FORTRANKW(nullify);
// FORTRANKW(only);
// FORTRANKW(operator);
// FORTRANKW(optional);
// FORTRANKW(pointer);
// FORTRANKW(private);
// FORTRANKW(procedure);
// FORTRANKW(public);
// FORTRANKW(recursive);
// FORTRANKW(result);
// FORTRANKW(select);
// FORTRANKW(sequence);
// FORTRANKW(target);
// FORTRANKW(use);
// FORTRANKW(while);
// FORTRANKW(where);

// Fortran 95
// FORTRANKW(elemental);
// FORTRANKW(forall);
// FORTRANKW(pure);

// Fortran 2003
// FORTRANKW(abstract);
// FORTRANKW(associate);
// FORTRANKW(asynchronous);
// FORTRANKW(bind);
// FORTRANKW(class);
// FORTRANKW(deferred);
// FORTRANKW(enum);
// FORTRANKW(enumerator);
// FORTRANKW(extends);
// FORTRANKW(final);
// FORTRANKW(flush);
// FORTRANKW(generic);
// FORTRANKW(import);
// FORTRANKW(non_overridable);
// FORTRANKW(nopass);
// FORTRANKW(pass);
// FORTRANKW(protected);
// FORTRANKW(value);
// FORTRANKW(volatile);
// FORTRANKW(wait);

#undef FORTRANKW


/* vim: set ts=2 sw=2 sts=2 tw=129 : */
