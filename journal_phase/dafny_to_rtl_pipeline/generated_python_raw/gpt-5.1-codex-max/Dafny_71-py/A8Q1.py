import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: A8Q1

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def min3(x, y, z):
        if ((x) <= (y)) and ((x) <= (z)):
            return x
        elif (y) <= (z):
            return y
        elif True:
            return z

    @staticmethod
    def FindMin(x, y, z):
        m: int = int(0)
        if ((x) <= (y)) and ((x) <= (z)):
            m = x
        elif ((y) <= (x)) and ((y) <= (z)):
            m = y
        elif True:
            m = z
        return m

