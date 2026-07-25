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
    def fib(n):
        if (n) == (0):
            return 0
        elif (n) == (1):
            return 1
        elif True:
            return (default__.fib((n) - (1))) + (default__.fib((n) - (2)))

    @staticmethod
    def Fib(n):
        result: int = int(0)
        if (n) == (0):
            result = 0
            return result
        d_0_a_: int
        d_0_a_ = 0
        d_1_b_: int
        d_1_b_ = 1
        d_2_i_: int
        d_2_i_ = 1
        while (d_2_i_) < (n):
            d_3_temp_: int
            d_3_temp_ = d_1_b_
            d_1_b_ = (d_0_a_) + (d_1_b_)
            d_0_a_ = d_3_temp_
            d_2_i_ = (d_2_i_) + (1)
        result = d_1_b_
        return result
        return result

