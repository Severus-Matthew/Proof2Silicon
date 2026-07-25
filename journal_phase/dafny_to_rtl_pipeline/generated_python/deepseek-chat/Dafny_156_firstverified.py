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
    def ArraySum(arr):
        sum_: int = int(0)
        sum_ = 0
        d_0_i_: int
        d_0_i_ = 0
        while (d_0_i_) < ((arr).length(0)):
            sum_ = (sum_) + ((arr)[d_0_i_])
            d_0_i_ = (d_0_i_) + (1)
        return sum_

    @staticmethod
    def SumOfArray(arr):
        if ((arr).length(0)) == (0):
            return 0
        elif True:
            return default__.SumOfArrayUpTo(arr, (arr).length(0))

    @staticmethod
    def SumOfArrayUpTo(arr, k):
        d_0___accumulator_ = 0
        while True:
            with _dafny.label():
                if (k) == (0):
                    return (0) + (d_0___accumulator_)
                elif True:
                    d_0___accumulator_ = ((arr)[(k) - (1)]) + (d_0___accumulator_)
                    in0_ = arr
                    in1_ = (k) - (1)
                    arr = in0_
                    k = in1_
                    raise _dafny.TailCall()
                break

