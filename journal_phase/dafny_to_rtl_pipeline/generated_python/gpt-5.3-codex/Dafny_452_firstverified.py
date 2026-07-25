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
    def ReverseInPlace(a):
        d_0_i_: int
        d_0_i_ = 0
        d_1_j_: int
        d_1_j_ = ((a).length(0)) - (1)
        while (d_0_i_) < (d_1_j_):
            d_2_t_: int
            d_2_t_ = (a)[d_0_i_]
            (a)[(d_0_i_)] = (a)[d_1_j_]
            (a)[(d_1_j_)] = d_2_t_
            d_0_i_ = (d_0_i_) + (1)
            d_1_j_ = (d_1_j_) - (1)

    @staticmethod
    def Demo():
        d_0_a_: _dafny.Array
        nw0_ = _dafny.Array(int(0), 5)
        d_0_a_ = nw0_
        rhs0_ = 10
        rhs1_ = 20
        rhs2_ = 30
        rhs3_ = 40
        rhs4_ = 50
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
        default__.ReverseInPlace(d_0_a_)
        d_1_e_: _dafny.Array
        nw1_ = _dafny.Array(int(0), 0)
        d_1_e_ = nw1_
        default__.ReverseInPlace(d_1_e_)
        d_2_s_: _dafny.Array
        nw2_ = _dafny.Array(int(0), 1)
        d_2_s_ = nw2_
        (d_2_s_)[(0)] = 7
        default__.ReverseInPlace(d_2_s_)

