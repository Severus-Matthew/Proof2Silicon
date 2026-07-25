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
    def Max(s):
        m: int = int(0)
        m = (s)[0]
        d_0_i_: int
        d_0_i_ = 1
        while (d_0_i_) < (len(s)):
            if ((s)[d_0_i_]) > (m):
                m = (s)[d_0_i_]
            d_0_i_ = (d_0_i_) + (1)
        return m

