import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: CheckSumCalculator


class CheckSumCalculator:
    def  __init__(self):
        self.checksum: _dafny.Seq = _dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, ""))
        pass

    def __dafnystr__(self) -> str:
        return "CheckSumCalculator.CheckSumCalculator"
    def ctor__(self):
        (self).checksum = _dafny.SeqWithoutIsStrInference([])

    def appendChar(self, c):
        if (len(self.checksum)) < (1000000):
            (self).checksum = (self.checksum) + (_dafny.SeqWithoutIsStrInference([c]))
        elif True:
            (self).checksum = _dafny.SeqWithoutIsStrInference([c])

    def getChecksum(self):
        result: _dafny.Seq = _dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, ""))
        result = self.checksum
        return result

    def verifyChecksum(self):
        valid: bool = False
        valid = (len(self.checksum)) > (0)
        return valid

