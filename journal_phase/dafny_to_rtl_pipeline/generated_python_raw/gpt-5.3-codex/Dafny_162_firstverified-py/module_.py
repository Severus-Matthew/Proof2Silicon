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
    def Minimum(a):
        min_: int = int(0)
        d_0_idx_: int
        d_0_idx_ = 0
        min_ = (a)[0]
        while (d_0_idx_) < ((a).length(0)):
            if ((a)[d_0_idx_]) < (min_):
                min_ = (a)[d_0_idx_]
            d_0_idx_ = (d_0_idx_) + (1)
        return min_

