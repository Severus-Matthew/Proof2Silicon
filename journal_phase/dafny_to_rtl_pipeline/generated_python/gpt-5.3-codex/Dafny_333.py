import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import Lowercase as Lowercase

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: Lowercase.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: Lowercase

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def IsUpper(c):
        return ((_dafny.CodePoint('A')) <= (c)) and ((c) <= (_dafny.CodePoint('Z')))

    @staticmethod
    def ToLowerChar(c):
        return _dafny.CodePoint(chr((ord(c)) + (32)))

    @staticmethod
    def IsLowercaseOrNonLetters(s):
        def lambda0_(forall_var_0_):
            d_0_i_: int = forall_var_0_
            return not (((0) <= (d_0_i_)) and ((d_0_i_) < (len(s)))) or (not(default__.IsUpper((s)[d_0_i_])))

        return _dafny.quantifier(_dafny.IntegerRange(0, len(s)), True, lambda0_)

    @staticmethod
    def ToLowercase(s):
        t: _dafny.Seq = _dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, ""))
        d_0_i_: int
        d_0_i_ = 0
        t = _dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, ""))
        while (d_0_i_) < (len(s)):
            if default__.IsUpper((s)[d_0_i_]):
                t = (t) + (_dafny.SeqWithoutIsStrInference([default__.ToLowerChar((s)[d_0_i_])]))
            elif True:
                t = (t) + (_dafny.SeqWithoutIsStrInference([(s)[d_0_i_]]))
            d_0_i_ = (d_0_i_) + (1)
        t = t
        return t
        return t

    @staticmethod
    def Check(s):
        result: bool = False
        d_0_t_: _dafny.Seq
        out0_: _dafny.Seq
        out0_ = default__.ToLowercase(s)
        d_0_t_ = out0_
        result = True
        return result
