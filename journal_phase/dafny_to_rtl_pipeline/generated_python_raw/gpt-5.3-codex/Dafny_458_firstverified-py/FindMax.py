import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: FindMax

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def FindMax(a):
        idx: int = int(0)
        maxVal: int = int(0)
        d_0_i_: int
        d_0_i_ = 1
        idx = 0
        maxVal = (a)[0]
        while (d_0_i_) < ((a).length(0)):
            if ((a)[d_0_i_]) > (maxVal):
                idx = d_0_i_
                maxVal = (a)[d_0_i_]
            d_0_i_ = (d_0_i_) + (1)
        return idx, maxVal

