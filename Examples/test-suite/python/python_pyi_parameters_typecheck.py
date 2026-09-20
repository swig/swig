# pyright: strict, reportUnnecessaryTypeIgnoreComment=true
from typing import List
import python_pyi_parameters as m

size: int = m.size1()
compact: int = m.compact(2)
plain: str = m.plain()
keyword: int = m.keywords(value=2)
grouped: int = m.grouped(["a", "b"])
output: int = m.output()
combined: List[int] = m.combined(2)
default_output: List[int] = m.combined_default()
w = m.Widget()
member: int = w.size1()
named: int = w.keyword(value=3)
static: int = m.Widget.make(3)

m.size1(1)  # type: ignore
m.compact("wrong")  # type: ignore
m.compact(1, 2, 3)  # type: ignore
m.compact(value=1)  # type: ignore
m.plain(3)  # type: ignore
m.keywords(unknown=1)  # type: ignore
m.grouped(3)  # type: ignore
m.output(1)  # type: ignore
wrong_output: str = m.combined_default()  # type: ignore
w.size1(1)  # type: ignore
w.keyword(value="wrong")  # type: ignore
m.Widget.make("wrong")  # type: ignore
m.Widget("wrong")  # type: ignore

from python_pyi_parameters import DirectorEmpty, DirectorDefault, DirectorParam, DirectorCopy, make_director_copy

class DerivedEmpty(DirectorEmpty):
    def __init__(self) -> None:
        super().__init__()

empty_director = DirectorEmpty()
default_director = DirectorDefault()
parameter_director = DirectorDefault(3)
required_director = DirectorParam(4)
copied_director = DirectorCopy(make_director_copy())
DirectorEmpty(1)  # type: ignore
DirectorDefault("wrong")  # type: ignore
DirectorDefault(1, 2)  # type: ignore
DirectorParam()  # type: ignore
DirectorParam("wrong")  # type: ignore
DirectorCopy(1)  # type: ignore

typemap_default: int = m.typemap_default()
typemap_argument: int = m.typemap_default(4)
typemap_keyword_default: int = m.typemap_default_keyword()
typemap_keyword: int = m.typemap_default_keyword(typemap_value=5)
m.typemap_default("wrong")  # type: ignore
m.typemap_default_keyword(typemap_value="wrong")  # type: ignore

keyword_director = m.DirectorKeyword(arg2=3)
m.DirectorKeyword(arg1=3)  # type: ignore

extended_qualified: str = m.Extended.qualified()
extended_bare: str = m.Extended.bare()
extended_instance: str = m.Extended().instance("text")
m.Extended().instance(None)  # type: ignore
