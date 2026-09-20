# pyright: strict, reportUnnecessaryTypeIgnoreComment=true
import python_pyi_skip as m

value: int = m.replaced(3)
w = m.Widget(5)
result: int = w.call(2, 3)
static_result: int = m.Widget.twice(4)
ordinary: int = w.ordinary(9)

m.hidden(3)  # type: ignore
w.internal(3)  # type: ignore
m.replaced("wrong")  # type: ignore
w.call("wrong")  # type: ignore
m.Widget.twice("wrong")  # type: ignore
m.Widget("wrong")  # type: ignore
