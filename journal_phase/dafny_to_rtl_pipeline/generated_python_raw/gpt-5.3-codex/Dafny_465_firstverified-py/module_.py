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
    def PrefixSums(a):
        p: _dafny.Array = _dafny.Array(None, 0)
        nw0_ = _dafny.Array(int(0), (a).length(0))
        p = nw0_
        if ((a).length(0)) == (0):
            return p
        d_0_i_: int
        d_0_i_ = 0
        d_1_running_: int
        d_1_running_ = 0
        while (d_0_i_) < ((a).length(0)):
            d_1_running_ = (d_1_running_) + ((a)[d_0_i_])
            (p)[(d_0_i_)] = d_1_running_
            d_0_i_ = (d_0_i_) + (1)
        return p

