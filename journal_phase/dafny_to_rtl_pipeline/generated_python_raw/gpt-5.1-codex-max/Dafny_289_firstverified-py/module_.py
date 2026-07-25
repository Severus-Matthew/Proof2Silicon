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
    def ElementWiseDivision(a, b):
        c: _dafny.Seq = _dafny.Seq({})
        d_0_arr_: _dafny.Array
        nw0_ = _dafny.Array(int(0), len(a))
        d_0_arr_ = nw0_
        d_1_i_: int
        d_1_i_ = 0
        while (d_1_i_) < (len(a)):
            (d_0_arr_)[(d_1_i_)] = _dafny.euclidian_division((a)[d_1_i_], (b)[d_1_i_])
            d_1_i_ = (d_1_i_) + (1)
        c = _dafny.SeqWithoutIsStrInference((d_0_arr_)[::])
        return c

