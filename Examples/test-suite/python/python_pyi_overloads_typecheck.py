# pyright: strict, reportUnnecessaryTypeIgnoreComment=true
from typing import Union
from python_pyi_overloads import Choice, choose, compact, conflicting, defaults, duplicate, multi, produced, ranked_arities, ranked_defaults

mapped: int = multi(["a", "b"])
floating: float = multi(2.5)
n: int = choose(3)
s: str = choose("hello")
a: int = defaults(2)
b: int = compact(2)
c: int = produced(2)
d: float = produced("hello")
e: int = duplicate(3)
f: Union[int, str] = conflicting(3)
instance = Choice(3)
g: int = instance.pick(3)
h: str = instance.pick("hello")
i: str = Choice.build("hello")
other = Choice("abc")

choose([])  # type: ignore
choose(n=3)  # type: ignore
wrong: int = choose("hello")  # type: ignore
wrong_output: str = produced(2)  # type: ignore
Choice([])  # type: ignore
instance.pick([])  # type: ignore
Choice.build([])  # type: ignore

ranked_default_int: int = ranked_defaults(2)
ranked_default_str: str = ranked_defaults(2.5)
ranked_arity_one: int = ranked_arities(2)
ranked_arity_bool: str = ranked_arities(2, True)
ranked_arity_int: int = ranked_arities(2, 3)
wrong_default: str = ranked_defaults(2)  # type: ignore
wrong_arity: int = ranked_arities(2, True)  # type: ignore

from python_pyi_overloads import DirectorChoice

class DerivedChoice(DirectorChoice):
    def __init__(self) -> None:
        super().__init__()

empty_director = DirectorChoice()
parameter_director = DirectorChoice(3)
explicit_director = DirectorChoice(3, 4)
copied_director = DirectorChoice(parameter_director)
DirectorChoice("wrong")  # type: ignore
DirectorChoice(1, 2, 3)  # type: ignore

from python_pyi_overloads import text_kind, text_defaults
scalar_text: str = text_kind("hello")
sequence_size: int = text_kind(["hello", "world"])
scalar_default: str = text_defaults("hello")
scalar_explicit: str = text_defaults("hello", 1)
sequence_default: int = text_defaults(["hello"])
sequence_explicit: int = text_defaults(["hello"], 3)
wrong_scalar: int = text_kind("hello")  # type: ignore
wrong_sequence: str = text_kind(["hello"])  # type: ignore
wrong_scalar_default: int = text_defaults("hello")  # type: ignore
wrong_sequence_default: str = text_defaults(["hello"])  # type: ignore

from python_pyi_overloads import typemap_default
typemap_omitted: int = typemap_default()
typemap_integer: int = typemap_default(3)
typemap_string: str = typemap_default("hello")
typemap_wrong: str = typemap_default()  # type: ignore
typemap_default([])  # type: ignore

from python_pyi_overloads import Extended
extended_qualified: str = Extended.qualified("text")
extended_bare: str = Extended.bare("text")
extended_instance: str = Extended().instance("text")
extended_number: int = Extended().instance(4)
extended_wrong: int = Extended.qualified("text")  # type: ignore
Extended().instance(None)  # type: ignore
