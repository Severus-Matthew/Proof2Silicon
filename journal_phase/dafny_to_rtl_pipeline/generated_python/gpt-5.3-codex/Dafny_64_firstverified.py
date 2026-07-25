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
    def Triple(x):
        r: int = int(0)
        if (x) == (0):
            r = 0
        elif True:
            r = (x) + ((2) * (x))
        return r

