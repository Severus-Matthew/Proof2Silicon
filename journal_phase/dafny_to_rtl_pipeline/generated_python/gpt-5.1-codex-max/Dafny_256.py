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
    def equals(x, y):
        return (x) == (y)

    @staticmethod
    def ContainsSequence(list_, sub):
        found: bool = False
        d_0_i_: int
        d_0_i_ = 0
        found = False
        while ((d_0_i_) < (len(list_))) and (not(found)):
            if ((list_)[d_0_i_]) == (sub):
                found = True
            d_0_i_ = (d_0_i_) + (1)
        return found

