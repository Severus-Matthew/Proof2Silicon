import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import Maximum as Maximum

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: Maximum.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: Maximum

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def Max(s):
        res: int = int(0)
        d_0_i_: int
        d_0_i_ = 1
        res = (s)[0]
        while (d_0_i_) < (len(s)):
            if ((s)[d_0_i_]) > (res):
                res = (s)[d_0_i_]
            d_0_i_ = (d_0_i_) + (1)
        return res

    @staticmethod
    def Main(noArgsParameter__):
        d_0_s_: _dafny.Seq
        d_0_s_ = _dafny.SeqWithoutIsStrInference([5, 1, 9, 2, 9, -3])
        d_1_m_: int
        out0_: int
        out0_ = default__.Max(d_0_s_)
        d_1_m_ = out0_
        _dafny.print(_dafny.string_of(d_1_m_))
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\n"))).VerbatimString(False))
