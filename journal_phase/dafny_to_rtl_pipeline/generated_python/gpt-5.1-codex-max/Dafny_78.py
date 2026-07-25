import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import Gen as Gen

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: Gen.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: Gen

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def GenerateSequence(n):
        s: _dafny.Seq = _dafny.Seq({})
        d_0_i_: int
        d_0_i_ = 0
        s = _dafny.SeqWithoutIsStrInference([])
        while (d_0_i_) < (n):
            s = (s) + (_dafny.SeqWithoutIsStrInference([d_0_i_]))
            d_0_i_ = (d_0_i_) + (1)
        return s
