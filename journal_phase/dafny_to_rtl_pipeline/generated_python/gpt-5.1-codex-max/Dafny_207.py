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
    def FindMax(arr):
        maxIndex: int = int(0)
        maxIndex = 0
        d_0_i_: int
        d_0_i_ = 1
        while (d_0_i_) < ((arr).length(0)):
            if ((arr)[d_0_i_]) > ((arr)[maxIndex]):
                maxIndex = d_0_i_
            d_0_i_ = (d_0_i_) + (1)
        return maxIndex

    @staticmethod
    def Main(noArgsParameter__):
        d_0_arr_: _dafny.Array
        nw0_ = _dafny.Array(int(0), 5)
        d_0_arr_ = nw0_
        (d_0_arr_)[(0)] = 1
        (d_0_arr_)[(1)] = 2
        (d_0_arr_)[(2)] = 3
        (d_0_arr_)[(3)] = 4
        (d_0_arr_)[(4)] = 5
        d_1_maxIndex_: int
        out0_: int
        out0_ = default__.FindMax(d_0_arr_)
        d_1_maxIndex_ = out0_
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "The index of the maximum element is: "))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_1_maxIndex_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\n"))).VerbatimString(False))

