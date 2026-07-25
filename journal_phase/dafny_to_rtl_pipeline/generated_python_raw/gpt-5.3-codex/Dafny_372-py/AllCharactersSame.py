import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: AllCharactersSame

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def CheckAllCharactersSame(s):
        r: bool = False
        d_0_i_: int
        d_0_i_ = 1
        r = True
        while (d_0_i_) < (len(s)):
            if ((s)[d_0_i_]) != ((s)[0]):
                r = False
            d_0_i_ = (d_0_i_) + (1)
        return r

