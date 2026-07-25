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
    def Main(noArgsParameter__):
        d_0_a_: _dafny.Array
        nw0_ = _dafny.Array(int(0), 5)
        d_0_a_ = nw0_
        rhs0_ = 1
        rhs1_ = 2
        rhs2_ = 3
        rhs3_ = 4
        rhs4_ = 5
        lhs0_ = d_0_a_
        lhs1_ = 0
        lhs2_ = d_0_a_
        lhs3_ = 1
        lhs4_ = d_0_a_
        lhs5_ = 2
        lhs6_ = d_0_a_
        lhs7_ = 3
        lhs8_ = d_0_a_
        lhs9_ = 4
        lhs0_[lhs1_] = rhs0_
        lhs2_[lhs3_] = rhs1_
        lhs4_[lhs5_] = rhs2_
        lhs6_[lhs7_] = rhs3_
        lhs8_[lhs9_] = rhs4_
        d_1_i_: int
        d_1_i_ = 0
        d_2_sum_: int
        d_2_sum_ = 0
        while (d_1_i_) < ((d_0_a_).length(0)):
            d_2_sum_ = (d_2_sum_) + ((d_0_a_)[d_1_i_])
            d_1_i_ = (d_1_i_) + (1)

