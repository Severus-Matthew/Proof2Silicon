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
    def SumPrefix(s, n):
        d_0___accumulator_ = 0
        while True:
            with _dafny.label():
                if (n) == (0):
                    return (0) + (d_0___accumulator_)
                elif True:
                    d_0___accumulator_ = ((s)[(n) - (1)]) + (d_0___accumulator_)
                    in0_ = s
                    in1_ = (n) - (1)
                    s = in0_
                    n = in1_
                    raise _dafny.TailCall()
                break

    @staticmethod
    def SumArraySpec(s):
        return default__.SumPrefix(s, len(s))

    @staticmethod
    def SumArray(arr):
        s: int = int(0)
        d_0_i_: int
        d_0_i_ = 0
        s = 0
        while (d_0_i_) < ((arr).length(0)):
            s = (s) + ((arr)[d_0_i_])
            d_0_i_ = (d_0_i_) + (1)
        return s

