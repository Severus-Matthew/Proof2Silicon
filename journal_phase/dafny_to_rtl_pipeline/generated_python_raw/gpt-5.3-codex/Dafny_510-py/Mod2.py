import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: Mod2

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def addSome(n):
        r: int = int(0)
        if (n) < (5):
            r = 6
        elif True:
            r = (n) + (1)
        return r

    @staticmethod
    def m(n):
        res: int = int(0)
        out0_: int
        out0_ = default__.addSome(n)
        res = out0_
        return res

