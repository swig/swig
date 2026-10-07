from cpp20_concepts_extra import *


def check_equal(a, b):
    if a != b:
        raise RuntimeError("{} is not equal to {}".format(a, b))


# Negation via parens: '(!Numeric<T>)' on a non-numeric type.
t = Tag(7)
out = identity_non_numeric_tag(t)
check_equal(out.value(), 7)

# Multi parameter requires-expression with mixed types.
check_equal(mix_add_id(2, 3.5), 5)
check_equal(mix_add_id(-4, 1.0), -3)

# Variadic concept defined by a fold-expression over '&&'.
check_equal(sum_all_iii(1, 2, 3), 6)
check_equal(sum_all_iii(-5, 10, 2), 7)
check_equal(sum_all_ddd(1.5, 2.5, 1.0), 5.0)

# Type trait primary used as a constraint atom.
check_equal(trait_primary_int(7), 14)
check_equal(trait_primary_int(-3), -6)

# Deeper nesting of '&&' and '||' inside parens.
check_equal(deeper_int(42), 42)
check_equal(deeper_int(-7), -7)

# Both prefix AND trailing requires-clauses on the same function template.
check_equal(both_clauses_int(5), 10)
check_equal(both_clauses_int(-3), -6)

# Default template argument paired with a requires-clause.
check_equal(identity_default_int(7), 7)
check_equal(identity_default_double(1.5), 1.5)

# Concept refinement - requires-clause spelled with a concept defined in terms of another.
check_equal(succ_int(5), 6)

# Trailing requires-clause on a non-template member of a class template.
h = ConstrainedHolderInt(4)
check_equal(h.cube(), 64)

# Concept bodies that are ordinary expressions rather than concept-id chains.
check_equal(pass_through_int(9), 9)

# A boolean literal as the whole constraint.
check_equal(literal_constraint_int(6), 6)

# A virt-specifier after the trailing requires-clause, both specifiers and both orderings.
d = VirtDerivedInt()
check_equal(d.plain(10), 11)
check_equal(d.arrow(10), 12)
check_equal(d.over(10), 13)
check_equal(d.over_arrow(10), 14)
check_equal(d.both(10), 15)
check_equal(d.both_reversed(10), 16)

# A type-constraint on an 'auto' variable placeholder, in each of the three initialiser forms.
check_equal(cvar.constrained_var, 42)
check_equal(cvar.constrained_braced_var, 1.5)
check_equal(cvar.constrained_multi1, 7)
check_equal(cvar.constrained_multi2, 8)
check_equal(cvar.constrained_decltype_auto_var, 42)
