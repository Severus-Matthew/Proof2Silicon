import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import AddSmallNumbers as AddSmallNumbers

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: AddSmallNumbers.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: AddSmallNumbers

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def sumSeq(s):
        d_0___accumulator_ = 0
        while True:
            with _dafny.label():
                if (len(s)) == (0):
                    return (0) + (d_0___accumulator_)
                elif True:
                    d_0___accumulator_ = (d_0___accumulator_) + ((s)[0])
                    in0_ = _dafny.SeqWithoutIsStrInference((s)[1::])
                    s = in0_
                    raise _dafny.TailCall()
                break

    @staticmethod
    def AddSmall(max_, a, n):
        r: int = int(0)
        d_0_i_: int
        d_0_i_ = 0
        r = 0
        while (d_0_i_) < (n):
            r = (r) + ((a)[d_0_i_])
            d_0_i_ = (d_0_i_) + (1)
        return r
