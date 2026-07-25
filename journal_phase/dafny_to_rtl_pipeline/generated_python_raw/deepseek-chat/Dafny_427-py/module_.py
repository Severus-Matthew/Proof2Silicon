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
    def Mult(x, y):
        r: int = int(0)
        r = 0
        d_0_i_: int
        d_0_i_ = x
        while (d_0_i_) > (0):
            r = (r) + (y)
            d_0_i_ = (d_0_i_) - (1)
        return r

