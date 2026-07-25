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
    def Max(arr):
        m: int = int(0)
        m = (arr)[0]
        d_0_i_: int
        d_0_i_ = 1
        while (d_0_i_) < ((arr).length(0)):
            if ((arr)[d_0_i_]) > (m):
                m = (arr)[d_0_i_]
            d_0_i_ = (d_0_i_) + (1)
        return m

    @staticmethod
    def Main(noArgsParameter__):
        d_0_a_: _dafny.Array
        nw0_ = _dafny.Array(int(0), 5)
        d_0_a_ = nw0_
        (d_0_a_)[(0)] = 3
        (d_0_a_)[(1)] = 1
        (d_0_a_)[(2)] = 7
        (d_0_a_)[(3)] = -2
        (d_0_a_)[(4)] = 5
        d_1_maximum_: int
        out0_: int
        out0_ = default__.Max(d_0_a_)
        d_1_maximum_ = out0_
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "The maximum value is: "))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_1_maximum_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\n"))).VerbatimString(False))

