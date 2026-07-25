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
    def Min(a):
        m: int = int(0)
        d_0_i_: int
        d_0_i_ = 0
        m = (a)[0]
        while (d_0_i_) < (((a).length(0)) - (1)):
            d_1_next_: int
            d_1_next_ = (a)[(d_0_i_) + (1)]
            if (d_1_next_) < (m):
                m = d_1_next_
            d_0_i_ = (d_0_i_) + (1)
        return m

