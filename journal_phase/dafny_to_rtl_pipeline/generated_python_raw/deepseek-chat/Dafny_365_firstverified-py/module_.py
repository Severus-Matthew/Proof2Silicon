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
    def FindEvenNumbers(a):
        evens: _dafny.Seq = _dafny.Seq({})
        d_0_result_: _dafny.Seq
        d_0_result_ = _dafny.SeqWithoutIsStrInference([])
        d_1_i_: int
        d_1_i_ = 0
        while (d_1_i_) < ((a).length(0)):
            if (_dafny.euclidian_modulus((a)[d_1_i_], 2)) == (0):
                d_0_result_ = (d_0_result_) + (_dafny.SeqWithoutIsStrInference([(a)[d_1_i_]]))
            d_1_i_ = (d_1_i_) + (1)
        evens = d_0_result_
        return evens
        return evens

