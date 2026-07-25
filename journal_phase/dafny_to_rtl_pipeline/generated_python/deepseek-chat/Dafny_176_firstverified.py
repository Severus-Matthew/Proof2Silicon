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
    def Abs(x):
        if (x) < (0):
            return (0) - (x)
        elif True:
            return x

    @staticmethod
    def AbsIt(x):
        r: int = int(0)
        if (x) < (0):
            r = (0) - (x)
        elif True:
            r = x
        return r

