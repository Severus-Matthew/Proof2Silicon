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
    def Sum(a, lo, hi):
        d_0___accumulator_ = 0
        while True:
            with _dafny.label():
                if (lo) == (hi):
                    return (0) + (d_0___accumulator_)
                elif True:
                    d_0___accumulator_ = ((a)[(hi) - (1)]) + (d_0___accumulator_)
                    in0_ = a
                    in1_ = lo
                    in2_ = (hi) - (1)
                    a = in0_
                    lo = in1_
                    hi = in2_
                    raise _dafny.TailCall()
                break

    @staticmethod
    def SumArray(a):
        sum_: int = int(0)
        d_0_i_: int
        d_0_i_ = 0
        sum_ = 0
        while (d_0_i_) < ((a).length(0)):
            sum_ = (sum_) + ((a)[d_0_i_])
            d_0_i_ = (d_0_i_) + (1)
        return sum_

