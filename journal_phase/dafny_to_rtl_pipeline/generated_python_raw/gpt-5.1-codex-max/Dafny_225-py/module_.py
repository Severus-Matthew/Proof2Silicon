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
    def sumSpec(f, n):
        d_0___accumulator_ = 0
        while True:
            with _dafny.label():
                if (n) == (0):
                    return (0) + (d_0___accumulator_)
                elif True:
                    d_0___accumulator_ = (d_0___accumulator_) + (f(n))
                    in0_ = f
                    in1_ = (n) - (1)
                    f = in0_
                    n = in1_
                    raise _dafny.TailCall()
                break

    @staticmethod
    def Sum(f, n):
        res: int = int(0)
        d_0_s_: int
        d_0_s_ = 0
        d_1_i_: int
        d_1_i_ = 0
        while (d_1_i_) < (n):
            d_1_i_ = (d_1_i_) + (1)
            d_0_s_ = (d_0_s_) + (f(d_1_i_))
        res = d_0_s_
        return res

