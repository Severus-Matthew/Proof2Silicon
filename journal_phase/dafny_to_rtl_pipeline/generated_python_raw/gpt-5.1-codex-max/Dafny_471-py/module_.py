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
    def Par(n):
        return (_dafny.euclidian_modulus(n, 2)) == (0)

    @staticmethod
    def FazAlgo(a, b):
        x: int = int(0)
        y: int = int(0)
        x = a
        y = b
        while (x) != (y):
            x = (x) - (2)
        return x, y

