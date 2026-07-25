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
    def NthOctagonalNumber(n):
        o: int = int(0)
        o = (n) * (((3) * (n)) - (2))
        return o

    @staticmethod
    def CheckNthOctagonalNumber(n):
        o: int = int(0)
        d_0_k_: int
        d_0_k_ = 0
        o = 0
        while (d_0_k_) < (n):
            d_0_k_ = (d_0_k_) + (1)
            o = (o) + (((6) * (d_0_k_)) - (5))
        d_1_direct_: int
        out0_: int
        out0_ = default__.NthOctagonalNumber(n)
        d_1_direct_ = out0_
        return o

    @staticmethod
    def Main(noArgsParameter__):
        d_0_a_: int
        out0_: int
        out0_ = default__.CheckNthOctagonalNumber(0)
        d_0_a_ = out0_
        d_1_b_: int
        out1_: int
        out1_ = default__.CheckNthOctagonalNumber(1)
        d_1_b_ = out1_
        d_2_c_: int
        out2_: int
        out2_ = default__.CheckNthOctagonalNumber(2)
        d_2_c_ = out2_
        d_3_d_: int
        out3_: int
        out3_ = default__.CheckNthOctagonalNumber(5)
        d_3_d_ = out3_

