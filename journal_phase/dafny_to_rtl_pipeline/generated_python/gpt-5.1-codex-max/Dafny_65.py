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
    def ComputeTriple(x):
        r: int = int(0)
        y: int = int(0)
        y = (2) * (x)
        r = (y) + (x)
        return r, y

    @staticmethod
    def Main(noArgsParameter__):
        d_0_r_: int = int(0)
        d_1_y_: int = int(0)
        out0_: int
        out1_: int
        out0_, out1_ = default__.ComputeTriple(4)
        d_0_r_ = out0_
        d_1_y_ = out1_

