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
    def IsPerfectSquare(n):
        result: bool = False
        d_0_i_: int
        d_0_i_ = 0
        while (d_0_i_) <= (n):
            if ((d_0_i_) * (d_0_i_)) == (n):
                result = True
                return result
            d_0_i_ = (d_0_i_) + (1)
        result = False
        return result

