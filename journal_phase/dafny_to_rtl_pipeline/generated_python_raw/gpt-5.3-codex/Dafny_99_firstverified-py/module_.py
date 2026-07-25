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
    def ComputeStairs(n):
        ways: int = int(0)
        if (n) == (0):
            ways = 1
            return ways
        if (n) == (1):
            ways = 1
            return ways
        d_0_prev2_: int
        d_0_prev2_ = 1
        d_1_prev1_: int
        d_1_prev1_ = 1
        d_2_i_: int
        d_2_i_ = 2
        while (d_2_i_) <= (n):
            d_3_curr_: int
            d_3_curr_ = (d_1_prev1_) + (d_0_prev2_)
            d_0_prev2_ = d_1_prev1_
            d_1_prev1_ = d_3_curr_
            d_2_i_ = (d_2_i_) + (1)
        ways = d_1_prev1_
        return ways

