import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: ContainsSequence

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def ContainsSequence(list_, sub):
        result: bool = False
        result = False
        d_0_i_: int
        d_0_i_ = 0
        while (d_0_i_) < (len(list_)):
            if ((list_)[d_0_i_]) == (sub):
                result = True
            d_0_i_ = (d_0_i_) + (1)
        return result

