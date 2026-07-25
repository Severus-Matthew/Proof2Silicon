import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: Test

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def positive(a, b):
        def lambda0_(forall_var_0_):
            d_0_i_: int = forall_var_0_
            return not (((a) <= (d_0_i_)) and ((d_0_i_) < (b))) or (((a) <= (d_0_i_)) and ((a) < (b)))

        return ((a) <= (b)) and (_dafny.quantifier(_dafny.IntegerRange(a, b), True, lambda0_))

    @staticmethod
    def mfirstNegative(a):
        idx: int = int(0)
        d_0_i_: int
        d_0_i_ = 0
        while (d_0_i_) < ((a).length(0)):
            if ((a)[d_0_i_]) < (0):
                idx = d_0_i_
                return idx
            d_0_i_ = (d_0_i_) + (1)
        idx = ((a).length(0)) - (1)
        return idx

