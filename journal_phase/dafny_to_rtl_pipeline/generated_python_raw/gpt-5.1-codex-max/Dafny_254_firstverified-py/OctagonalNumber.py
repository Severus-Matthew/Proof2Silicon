import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: OctagonalNumber

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def ComputeOctagonal(n):
        result: int = int(0)
        if (n) == (0):
            result = 0
        elif True:
            result = (n) * (((3) * (n)) - (2))
        return result

