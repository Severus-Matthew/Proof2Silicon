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
    def Valid(self):
        return (len(self.checksum)) <= ((self).MAX__LEN)

    def ctor__(self):
        (self).checksum = _dafny.SeqWithoutIsStrInference([])

    def AppendChar(self, c):
        result: _dafny.Seq = _dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, ""))
        (self).checksum = (self.checksum) + (_dafny.SeqWithoutIsStrInference([c]))
        if (len(self.checksum)) > ((self).MAX__LEN):
            (self).checksum = _dafny.SeqWithoutIsStrInference([])
        result = self.checksum
        return result

    def VerifyChecksum(self):
        ok: bool = False
        ok = (len(self.checksum)) <= ((self).MAX__LEN)
        return ok

    def GetChecksum(self):
        result: _dafny.Seq = _dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, ""))
        result = self.checksum
        return result

    def GetChecksumAndVerify(self):
        result: _dafny.Seq = _dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, ""))
        ok: bool = False
        result = self.checksum
        ok = (len(self.checksum)) <= ((self).MAX__LEN)
        return result, ok

    def GetChecksumAndVerifyAndAppendChar(self, c):
        result: _dafny.Seq = _dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, ""))
        ok: bool = False
        (self).checksum = (self.checksum) + (_dafny.SeqWithoutIsStrInference([c]))
        if (len(self.checksum)) > ((self).MAX__LEN):
            (self).checksum = _dafny.SeqWithoutIsStrInference([])
        result = self.checksum
        ok = (len(self.checksum)) <= ((self).MAX__LEN)
        return result, ok

    @property
    def MAX__LEN(self):
        return 1000000
