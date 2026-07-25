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
    def SumUpTo(n):
        sum_: int = int(0)
        d_0_i_: int
        d_0_i_ = 0
        sum_ = 0
        while (d_0_i_) <= (n):
            sum_ = (sum_) + (d_0_i_)
            d_0_i_ = (d_0_i_) + (1)
        return sum_

    @staticmethod
    def CheckSumUpTo():
        d_0_s0_: int
        out0_: int
        out0_ = default__.SumUpTo(0)
        d_0_s0_ = out0_
        d_1_s1_: int
        out1_: int
        out1_ = default__.SumUpTo(1)
        d_1_s1_ = out1_
        d_2_s5_: int
        out2_: int
        out2_ = default__.SumUpTo(5)
        d_2_s5_ = out2_
        d_3_s10_: int
        out3_: int
        out3_ = default__.SumUpTo(10)
        d_3_s10_ = out3_
        d_4_i_: int
        d_4_i_ = 0
        while (d_4_i_) < (20):
            d_5_a_: int
            out4_: int
            out4_ = default__.SumUpTo(d_4_i_)
            d_5_a_ = out4_
            d_6_b_: int
            out5_: int
            out5_ = default__.SumUpTo((d_4_i_) + (1))
            d_6_b_ = out5_
            d_4_i_ = (d_4_i_) + (1)

    @staticmethod
    def Main(noArgsParameter__):
        default__.CheckSumUpTo()
        d_0_n_: int
        d_0_n_ = 12
        d_1_result_: int
        out0_: int
        out0_ = default__.SumUpTo(d_0_n_)
        d_1_result_ = out0_

