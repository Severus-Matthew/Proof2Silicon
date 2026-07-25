import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: module_

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def RemoveElement(s, k):
        v: _dafny.Array = _dafny.Array(None, 0)
        nw0_ = _dafny.Array(int(0), ((s).length(0)) - (1))
        v = nw0_
        d_0_i_: int
        d_0_i_ = 0
        while (d_0_i_) < (k):
            (v)[(d_0_i_)] = (s)[d_0_i_]
            d_0_i_ = (d_0_i_) + (1)
        while (d_0_i_) < ((v).length(0)):
            (v)[(d_0_i_)] = (s)[(d_0_i_) + (1)]
            d_0_i_ = (d_0_i_) + (1)
        return v

