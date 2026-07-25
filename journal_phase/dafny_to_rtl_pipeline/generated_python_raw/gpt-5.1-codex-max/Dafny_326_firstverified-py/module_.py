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
    def Sum(n):
        res: int = int(0)
        d_0_i_: int
        d_0_i_ = 1
        d_1_sum_: int
        d_1_sum_ = 0
        while (d_0_i_) <= (n):
            d_1_sum_ = (d_1_sum_) + (d_0_i_)
            d_0_i_ = (d_0_i_) + (1)
        res = d_1_sum_
        return res

    @staticmethod
    def Main(noArgsParameter__):
        d_0_n_: int
        d_0_n_ = 10
        d_1_s_: int
        out0_: int
        out0_ = default__.Sum(d_0_n_)
        d_1_s_ = out0_
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "Sum of numbers from 1 to "))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_0_n_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, " is "))).VerbatimString(False))
        _dafny.print(_dafny.string_of(d_1_s_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\n"))).VerbatimString(False))

