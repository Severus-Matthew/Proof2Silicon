import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: FindNegativeNumbers

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def FindNegativeNumbers(arr):
        negIdx: _dafny.Seq = _dafny.Seq({})
        d_0_i_: int
        d_0_i_ = 0
        negIdx = _dafny.SeqWithoutIsStrInference([])
        while (d_0_i_) < ((arr).length(0)):
            if ((arr)[d_0_i_]) < (0):
                negIdx = (negIdx) + (_dafny.SeqWithoutIsStrInference([d_0_i_]))
            d_0_i_ = (d_0_i_) + (1)
        return negIdx

