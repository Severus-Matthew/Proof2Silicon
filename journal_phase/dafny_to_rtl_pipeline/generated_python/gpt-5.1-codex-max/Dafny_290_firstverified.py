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
    def SplitArray(arr, L):
        firstPart: _dafny.Seq = _dafny.Seq({})
        secondPart: _dafny.Seq = _dafny.Seq({})
        firstPart = _dafny.SeqWithoutIsStrInference((arr)[:L:])
        secondPart = _dafny.SeqWithoutIsStrInference((arr)[L::])
        return firstPart, secondPart

