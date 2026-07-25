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
        d_0_i_: int
        d_0_i_ = 0
        evens = _dafny.SeqWithoutIsStrInference([])
        while (d_0_i_) < ((a).length(0)):
            if (_dafny.euclidian_modulus((a)[d_0_i_], 2)) == (0):
                evens = (evens) + (_dafny.SeqWithoutIsStrInference([(a)[d_0_i_]]))
            d_0_i_ = (d_0_i_) + (1)
        return evens

