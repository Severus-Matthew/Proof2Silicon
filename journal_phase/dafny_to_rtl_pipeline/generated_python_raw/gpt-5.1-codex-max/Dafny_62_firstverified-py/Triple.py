import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: Triple

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def TripleNumber(x):
        r: int = int(0)
        r = (3) * (x)
        return r

