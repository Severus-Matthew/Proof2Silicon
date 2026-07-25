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
    def Max(a, b):
        if (a) >= (b):
            return a
        elif True:
            return b

    @staticmethod
    def Main(noArgsParameter__):
        d_0_r_: int
        d_0_r_ = 1

    @_dafny.classproperty
    def INT__MIN(instance):
        return -2147483648
    @_dafny.classproperty
    def INT__MAX(instance):
        return 2147483647
