#ifndef RUST_RUSTKW_SWG_
#define RUST_RUSTKW_SWG_

/* Warnings for Rust keywords. */
#define RUSTKW(x) %keywordwarn("'" `x` "' is a Rust keyword",rename="%s_") `x`

RUSTKW(Self);
RUSTKW(as);
RUSTKW(async);
RUSTKW(await);
RUSTKW(become);
RUSTKW(box);
RUSTKW(break);
RUSTKW(const);
RUSTKW(continue);
RUSTKW(crate);
RUSTKW(do);
RUSTKW(dyn);
RUSTKW(else);
RUSTKW(enum);
RUSTKW(extern);
RUSTKW(false);
RUSTKW(final);
RUSTKW(fn);
RUSTKW(for);
RUSTKW(if);
RUSTKW(impl);
RUSTKW(in);
RUSTKW(let);
RUSTKW(loop);
RUSTKW(macro);
RUSTKW(match);
RUSTKW(mod);
RUSTKW(move);
RUSTKW(mut);
RUSTKW(override);
RUSTKW(priv);
RUSTKW(pub);
RUSTKW(ref);
RUSTKW(return);
RUSTKW(self);
RUSTKW(static);
RUSTKW(struct);
RUSTKW(super);
RUSTKW(trait);
RUSTKW(true);
RUSTKW(try);
RUSTKW(type);
RUSTKW(typeof);
RUSTKW(unsafe);
RUSTKW(use);
RUSTKW(virtual);
RUSTKW(where);
RUSTKW(while);
RUSTKW(yield);

#undef RUSTKW

#endif /* RUST_RUSTKW_SWG_ */
