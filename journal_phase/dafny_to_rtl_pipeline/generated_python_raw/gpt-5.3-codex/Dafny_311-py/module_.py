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
    def AnalyzeArray(a):
        sum_: int = int(0)
        minVal: int = int(0)
        maxVal: int = int(0)
        hasNegative: bool = False
        d_0_i_: int
        d_0_i_ = 0
        sum_ = 0
        minVal = (a)[0]
        maxVal = (a)[0]
        hasNegative = False
        while (d_0_i_) < ((a).length(0)):
            sum_ = (sum_) + ((a)[d_0_i_])
            if (d_0_i_) == (0):
                minVal = (a)[d_0_i_]
                maxVal = (a)[d_0_i_]
            elif True:
                if ((a)[d_0_i_]) < (minVal):
                    minVal = (a)[d_0_i_]
                if ((a)[d_0_i_]) > (maxVal):
                    maxVal = (a)[d_0_i_]
            if ((a)[d_0_i_]) < (0):
                hasNegative = True
            d_0_i_ = (d_0_i_) + (1)
        return sum_, minVal, maxVal, hasNegative

    @staticmethod
    def SumSpec(a):
        return default__.SumPrefix(a, (a).length(0))

    @staticmethod
    def MinSpec(a):
        return default__.MinPrefix(a, (a).length(0))

    @staticmethod
    def MaxSpec(a):
        return default__.MaxPrefix(a, (a).length(0))

    @staticmethod
    def ExistsNegative(a):
        return default__.ExistsNegativePrefix(a, (a).length(0))

    @staticmethod
    def SumPrefix(a, n):
        d_0___accumulator_ = 0
        while True:
            with _dafny.label():
                if (n) == (0):
                    return (0) + (d_0___accumulator_)
                elif True:
                    d_0___accumulator_ = ((a)[(n) - (1)]) + (d_0___accumulator_)
                    in0_ = a
                    in1_ = (n) - (1)
                    a = in0_
                    n = in1_
                    raise _dafny.TailCall()
                break

    @staticmethod
    def MinPrefix(a, n):
        if (n) == (0):
            return (a)[0]
        elif (n) == (1):
            return (a)[0]
        elif True:
            d_0_prev_ = default__.MinPrefix(a, (n) - (1))
            if ((a)[(n) - (1)]) < (d_0_prev_):
                return (a)[(n) - (1)]
            elif True:
                return d_0_prev_

    @staticmethod
    def MaxPrefix(a, n):
        if (n) == (0):
            return (a)[0]
        elif (n) == (1):
            return (a)[0]
        elif True:
            d_0_prev_ = default__.MaxPrefix(a, (n) - (1))
            if ((a)[(n) - (1)]) > (d_0_prev_):
                return (a)[(n) - (1)]
            elif True:
                return d_0_prev_

    @staticmethod
    def ExistsNegativePrefix(a, n):
        if (n) == (0):
            return False
        elif True:
            return (default__.ExistsNegativePrefix(a, (n) - (1))) or (((a)[(n) - (1)]) < (0))

