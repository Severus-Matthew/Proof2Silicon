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
    def SplitArray(arr, L):
        firstPart: _dafny.Seq = _dafny.Seq({})
        secondPart: _dafny.Seq = _dafny.Seq({})
        firstPart = _dafny.SeqWithoutIsStrInference([])
        secondPart = _dafny.SeqWithoutIsStrInference([])
        d_0_i_: int
        d_0_i_ = 0
        while (d_0_i_) < (L):
            firstPart = (firstPart) + (_dafny.SeqWithoutIsStrInference([(arr)[d_0_i_]]))
            d_0_i_ = (d_0_i_) + (1)
        d_0_i_ = L
        while (d_0_i_) < ((arr).length(0)):
            secondPart = (secondPart) + (_dafny.SeqWithoutIsStrInference([(arr)[d_0_i_]]))
            d_0_i_ = (d_0_i_) + (1)
        return firstPart, secondPart

