import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: StepwiseTemplate

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def SumUpTo(n):
        s: int = int(0)
        d_0_i_: int
        d_0_i_ = 0
        s = 0
        while (d_0_i_) < (n):
            d_0_i_ = (d_0_i_) + (1)
            s = (s) + (d_0_i_)
        return s

    @staticmethod
    def ReverseIntoFresh(a):
        b: _dafny.Array = _dafny.Array(None, 0)
        nw0_ = _dafny.Array(int(0), (a).length(0))
        b = nw0_
        d_0_i_: int
        d_0_i_ = 0
        while (d_0_i_) < ((a).length(0)):
            (b)[(d_0_i_)] = (a)[(((a).length(0)) - (1)) - (d_0_i_)]
            d_0_i_ = (d_0_i_) + (1)
        return b

    @staticmethod
    def MaxWithFirstIndex(a):
        maxVal: int = int(0)
        idx: int = int(0)
        d_0_i_: int
        d_0_i_ = 1
        idx = 0
        maxVal = (a)[0]
        while (d_0_i_) < ((a).length(0)):
            if ((a)[d_0_i_]) > (maxVal):
                maxVal = (a)[d_0_i_]
                idx = d_0_i_
            d_0_i_ = (d_0_i_) + (1)
        return maxVal, idx

    @staticmethod
    def Demo():
        d_0_s_: int
        out0_: int
        out0_ = default__.SumUpTo(10)
        d_0_s_ = out0_
        d_1_arr_: _dafny.Array
        nw0_ = _dafny.Array(int(0), 5)
        d_1_arr_ = nw0_
        rhs0_ = 3
        rhs1_ = -1
        rhs2_ = 7
        rhs3_ = 7
        rhs4_ = 2
        lhs0_ = d_1_arr_
        lhs1_ = 0
        lhs2_ = d_1_arr_
        lhs3_ = 1
        lhs4_ = d_1_arr_
        lhs5_ = 2
        lhs6_ = d_1_arr_
        lhs7_ = 3
        lhs8_ = d_1_arr_
        lhs9_ = 4
        lhs0_[lhs1_] = rhs0_
        lhs2_[lhs3_] = rhs1_
        lhs4_[lhs5_] = rhs2_
        lhs6_[lhs7_] = rhs3_
        lhs8_[lhs9_] = rhs4_
        d_2_rev_: _dafny.Array
        out1_: _dafny.Array
        out1_ = default__.ReverseIntoFresh(d_1_arr_)
        d_2_rev_ = out1_
        d_3_m_: int
        d_4_p_: int
        out2_: int
        out3_: int
        out2_, out3_ = default__.MaxWithFirstIndex(d_1_arr_)
        d_3_m_ = out2_
        d_4_p_ = out3_

