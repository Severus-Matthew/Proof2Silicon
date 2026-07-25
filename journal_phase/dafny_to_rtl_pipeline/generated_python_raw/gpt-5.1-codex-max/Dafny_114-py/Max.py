import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: Max

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def Max(a, b):
        if (a) >= (b):
            return a
        elif True:
            return b

    @staticmethod
    def ComputeMax(a, b):
        c: int = int(0)
        if (a) >= (b):
            c = a
        elif True:
            c = b
        return c

