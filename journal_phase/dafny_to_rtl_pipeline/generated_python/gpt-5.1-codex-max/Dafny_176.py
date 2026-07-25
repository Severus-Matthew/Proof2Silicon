import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: module_


class AbsClass:
    def  __init__(self):
        pass

    def __dafnystr__(self) -> str:
        return "_module.AbsClass"
    def AbsIt(self, xs):
        d_0_i_: int
        d_0_i_ = 0
        while (d_0_i_) < ((xs).length(0)):
            if ((xs)[d_0_i_]) < (0):
                (xs)[(d_0_i_)] = (0) - ((xs)[d_0_i_])
            d_0_i_ = (d_0_i_) + (1)

