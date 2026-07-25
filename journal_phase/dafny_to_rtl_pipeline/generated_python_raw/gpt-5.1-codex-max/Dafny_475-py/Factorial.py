import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: Factorial

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def Fat(n):
        res: int = int(0)
        d_0_i_: int
        d_0_i_ = 0
        res = 1
        while (d_0_i_) < (n):
            d_0_i_ = (d_0_i_) + (1)
            res = (res) * (d_0_i_)
        return res

    @staticmethod
    def Compute(n):
        res: int = int(0)
        out0_: int
        out0_ = default__.Fat(n)
        res = out0_
        return res

