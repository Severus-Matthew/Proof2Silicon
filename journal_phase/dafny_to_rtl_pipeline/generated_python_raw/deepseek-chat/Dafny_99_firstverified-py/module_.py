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
    def Stairs(n):
        if (n) == (1):
            return 1
        elif (n) == (2):
            return 2
        elif True:
            return (default__.Stairs((n) - (1))) + (default__.Stairs((n) - (2)))

    @staticmethod
    def ComputeStairs(n):
        result: int = int(0)
        if (n) == (1):
            result = 1
        elif (n) == (2):
            result = 2
        elif True:
            d_0_a_: int
            d_0_a_ = 1
            d_1_b_: int
            d_1_b_ = 2
            d_2_i_: int
            d_2_i_ = 3
            while (d_2_i_) <= (n):
                d_3_c_: int
                d_3_c_ = (d_0_a_) + (d_1_b_)
                d_0_a_ = d_1_b_
                d_1_b_ = d_3_c_
                d_2_i_ = (d_2_i_) + (1)
            result = d_1_b_
        return result

