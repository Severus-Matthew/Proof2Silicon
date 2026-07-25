import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: BinarySearchModule

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def Sorted(a, lo, hi):
        def lambda0_(forall_var_0_):
            def lambda1_(forall_var_1_):
                d_1_j_: int = forall_var_1_
                return not ((((lo) <= (d_0_i_)) and ((d_0_i_) <= (d_1_j_))) and ((d_1_j_) < (hi))) or (((a)[d_0_i_]) <= ((a)[d_1_j_]))

            d_0_i_: int = forall_var_0_
            return _dafny.quantifier(_dafny.IntegerRange(d_0_i_, hi), True, lambda1_)

        return _dafny.quantifier(_dafny.IntegerRange(lo, (hi) + (1)), True, lambda0_)

    @staticmethod
    def BinarySearch(a, key):
        idx: int = int(0)
        d_0_lo_: int
        d_0_lo_ = 0
        d_1_hi_: int
        d_1_hi_ = (a).length(0)
        while (d_0_lo_) < (d_1_hi_):
            d_2_mid_: int
            d_2_mid_ = (d_0_lo_) + (_dafny.euclidian_division((d_1_hi_) - (d_0_lo_), 2))
            if ((a)[d_2_mid_]) == (key):
                idx = d_2_mid_
                return idx
            elif ((a)[d_2_mid_]) < (key):
                d_0_lo_ = (d_2_mid_) + (1)
            elif True:
                d_1_hi_ = d_2_mid_
        idx = -1
        return idx

    @staticmethod
    def CheckBinarySearch():
        d_0_a_: _dafny.Array
        nw0_ = _dafny.Array(int(0), 7)
        d_0_a_ = nw0_
        rhs0_ = 1
        rhs1_ = 3
        rhs2_ = 5
        rhs3_ = 7
        rhs4_ = 9
        rhs5_ = 11
        rhs6_ = 13
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
        lhs10_ = d_0_a_
        lhs11_ = 5
        lhs12_ = d_0_a_
        lhs13_ = 6
        lhs0_[lhs1_] = rhs0_
        lhs2_[lhs3_] = rhs1_
        lhs4_[lhs5_] = rhs2_
        lhs6_[lhs7_] = rhs3_
        lhs8_[lhs9_] = rhs4_
        lhs10_[lhs11_] = rhs5_
        lhs12_[lhs13_] = rhs6_
        d_1_i_: int
        out0_: int
        out0_ = default__.BinarySearch(d_0_a_, 1)
        d_1_i_ = out0_
        out1_: int
        out1_ = default__.BinarySearch(d_0_a_, 7)
        d_1_i_ = out1_
        out2_: int
        out2_ = default__.BinarySearch(d_0_a_, 13)
        d_1_i_ = out2_
        out3_: int
        out3_ = default__.BinarySearch(d_0_a_, 8)
        d_1_i_ = out3_
        d_2_b_: _dafny.Array
        nw1_ = _dafny.Array(int(0), 0)
        d_2_b_ = nw1_
        out4_: int
        out4_ = default__.BinarySearch(d_2_b_, 42)
        d_1_i_ = out4_
        d_3_c_: _dafny.Array
        nw2_ = _dafny.Array(int(0), 5)
        d_3_c_ = nw2_
        rhs7_ = 2
        rhs8_ = 2
        rhs9_ = 2
        rhs10_ = 2
        rhs11_ = 2
        lhs14_ = d_3_c_
        lhs15_ = 0
        lhs16_ = d_3_c_
        lhs17_ = 1
        lhs18_ = d_3_c_
        lhs19_ = 2
        lhs20_ = d_3_c_
        lhs21_ = 3
        lhs22_ = d_3_c_
        lhs23_ = 4
        lhs14_[lhs15_] = rhs7_
        lhs16_[lhs17_] = rhs8_
        lhs18_[lhs19_] = rhs9_
        lhs20_[lhs21_] = rhs10_
        lhs22_[lhs23_] = rhs11_
        out5_: int
        out5_ = default__.BinarySearch(d_3_c_, 2)
        d_1_i_ = out5_
        out6_: int
        out6_ = default__.BinarySearch(d_3_c_, 3)
        d_1_i_ = out6_

