from langobj import *


x ="hello"

if identity(x) != x:
    raise RuntimeError
