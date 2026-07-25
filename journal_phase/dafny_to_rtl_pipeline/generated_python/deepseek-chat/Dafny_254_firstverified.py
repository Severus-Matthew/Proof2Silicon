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
    def NthOctagonalNumber(n):
        return (n) * (((3) * (n)) - (2))

    @staticmethod
    def CheckNthOctagonalNumber(n):
        d_0_result_ = default__.NthOctagonalNumber(n)
        return (d_0_result_) == ((n) * (((3) * (n)) - (2)))

    @staticmethod
    def ComputeAndCheckOctagonalNumbers():
        pass
        pass

