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
    def BinarySearch(arr, key):
        idx: int = int(0)
        d_0_low_: int
        d_0_low_ = 0
        d_1_high_: int
        d_1_high_ = ((arr).length(0)) - (1)
        while (d_0_low_) <= (d_1_high_):
            d_2_mid_: int
            d_2_mid_ = (d_0_low_) + (_dafny.euclidian_division((d_1_high_) - (d_0_low_), 2))
            if ((arr)[d_2_mid_]) == (key):
                idx = d_2_mid_
                return idx
            elif ((arr)[d_2_mid_]) < (key):
                d_0_low_ = (d_2_mid_) + (1)
            elif True:
                d_1_high_ = (d_2_mid_) - (1)
        idx = -1
        return idx

    @staticmethod
    def Main(noArgsParameter__):
        d_0_a_: _dafny.Array
        nw0_ = _dafny.Array(int(0), 5)
        d_0_a_ = nw0_
        (d_0_a_)[(0)] = 1
        (d_0_a_)[(1)] = 3
        (d_0_a_)[(2)] = 5
        (d_0_a_)[(3)] = 7
        (d_0_a_)[(4)] = 9
        d_1_i1_: int
        out0_: int
        out0_ = default__.BinarySearch(d_0_a_, 7)
        d_1_i1_ = out0_
        d_2_i2_: int
        out1_: int
        out1_ = default__.BinarySearch(d_0_a_, 2)
        d_2_i2_ = out1_

