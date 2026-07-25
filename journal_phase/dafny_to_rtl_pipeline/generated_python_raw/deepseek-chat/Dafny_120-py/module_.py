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
    def UseConstructToDescribePurpose(input_):
        output: _dafny.Seq = _dafny.Seq({})
        output = _dafny.SeqWithoutIsStrInference([])
        d_0_i_: int
        d_0_i_ = 0
        while (d_0_i_) < (len(input_)):
            output = (output) + (_dafny.SeqWithoutIsStrInference([(input_)[((len(input_)) - (1)) - (d_0_i_)]]))
            d_0_i_ = (d_0_i_) + (1)
        return output

