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
    def sorted__seg(a, l, h):
        def lambda0_(forall_var_0_):
            d_0_i_: int = forall_var_0_
            return not (((l) <= (d_0_i_)) and ((d_0_i_) < ((h) - (1)))) or (((a)[d_0_i_]) <= ((a)[(d_0_i_) + (1)]))

        return _dafny.quantifier(_dafny.IntegerRange(l, (h) - (1)), True, lambda0_)

    @staticmethod
    def Segment(a, l, h):
        return _dafny.SeqWithoutIsStrInference((a)[l:h:])

    @staticmethod
    def sort__segment(a, l, h):
        pass
        pass

