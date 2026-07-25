import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: SumReasoning

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def Sum(f, n):
        d_0___accumulator_ = 0
        while True:
            with _dafny.label():
                if (n) == (0):
                    return (f(0)) + (d_0___accumulator_)
                elif True:
                    d_0___accumulator_ = (f(n)) + (d_0___accumulator_)
                    in0_ = f
                    in1_ = (n) - (1)
                    f = in0_
                    n = in1_
                    raise _dafny.TailCall()
                break

    @staticmethod
    def SumPrefix(f, n):
        d_0___accumulator_ = 0
        while True:
            with _dafny.label():
                if (n) == (0):
                    return (f(0)) + (d_0___accumulator_)
                elif True:
                    d_0___accumulator_ = (f(n)) + (d_0___accumulator_)
                    in0_ = f
                    in1_ = (n) - (1)
                    f = in0_
                    n = in1_
                    raise _dafny.TailCall()
                break

