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
        max_: int = int(0)
        max_ = (arr)[0]
        d_0_i_: int
        d_0_i_ = 1
        while (d_0_i_) < ((arr).length(0)):
            if ((arr)[d_0_i_]) > (max_):
                max_ = (arr)[d_0_i_]
            d_0_i_ = (d_0_i_) + (1)
        return max_

    @staticmethod
    def Main(noArgsParameter__):
        d_0_a_: _dafny.Array
        nw0_ = _dafny.Array(None, 5)
        nw0_[int(0)] = 3
        nw0_[int(1)] = 7
        nw0_[int(2)] = 2
        nw0_[int(3)] = 9
        nw0_[int(4)] = 5
        d_0_a_ = nw0_
        d_1_m_: int
        out0_: int
        out0_ = default__.FindMax(d_0_a_)
        d_1_m_ = out0_
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "Maximum element is: "))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_1_m_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\n"))).VerbatimString(False))

