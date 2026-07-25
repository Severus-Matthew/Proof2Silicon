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
    def SeqSumPrefix(s, n):
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
    def SeqSum(s):
        return default__.SeqSumPrefix(s, len(s))

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

    @staticmethod
    def RollingMax(a):
        r: _dafny.Seq = _dafny.Seq({})
        d_0_i_: int
        d_0_i_ = 0
        d_1_acc_: int
        d_1_acc_ = 0
        r = _dafny.SeqWithoutIsStrInference([])
        while (d_0_i_) < (len(a)):
            d_1_acc_ = (d_1_acc_) + ((a)[d_0_i_])
            r = (r) + (_dafny.SeqWithoutIsStrInference([d_1_acc_]))
            d_0_i_ = (d_0_i_) + (1)
        return r

