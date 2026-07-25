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
    def Abs(i):
        if (i) >= (0):
            return i
        elif True:
            return (0) - (i)

    @staticmethod
    def Max(a, b):
        if (a) >= (b):
            return a
        elif True:
            return b

    @staticmethod
    def TestingAbs():
        d_0_x_: int
        d_0_x_ = default__.Abs(5)
        d_1_y_: int
        d_1_y_ = default__.Abs(-3)

    @staticmethod
    def TestingAbs2():
        pass
        pass

    @staticmethod
    def TestingMax():
        pass
        pass

