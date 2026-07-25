import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: Arithmetic

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def SumUp(n):
        sum_: int = int(0)
        d_0_i_: int
        d_0_i_ = 1
        sum_ = 0
        while (d_0_i_) <= (n):
            sum_ = (sum_) + (d_0_i_)
            d_0_i_ = (d_0_i_) + (1)
        return sum_

