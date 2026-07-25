import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: AddLists

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def Add(a, b):
        result: _dafny.Array = _dafny.Array(None, 0)
        nw0_ = _dafny.Array(int(0), (a).length(0))
        result = nw0_
        d_0_i_: int
        d_0_i_ = 0
        while (d_0_i_) < ((a).length(0)):
            (result)[(d_0_i_)] = ((a)[d_0_i_]) + ((b)[d_0_i_])
            d_0_i_ = (d_0_i_) + (1)
        return result

