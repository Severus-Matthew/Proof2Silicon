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
    def AllCharactersSame(s):
        if (len(s)) == (0):
            return True
        elif True:
            def lambda0_(forall_var_0_):
                d_0_i_: int = forall_var_0_
                return not (((0) <= (d_0_i_)) and ((d_0_i_) < (len(s)))) or (((s)[d_0_i_]) == ((s)[0]))

            return _dafny.quantifier(_dafny.IntegerRange(0, len(s)), True, lambda0_)

    @staticmethod
    def Main(noArgsParameter__):
        d_0_testStrings_: _dafny.Seq
        d_0_testStrings_ = _dafny.SeqWithoutIsStrInference([_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "a")), _dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "abababab")), _dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "aaabbb"))])
        d_1_results_: _dafny.Seq
        d_1_results_ = _dafny.SeqWithoutIsStrInference([])
        d_2_i_: int
        d_2_i_ = 0
        while (d_2_i_) < (len(d_0_testStrings_)):
            d_1_results_ = (d_1_results_) + (_dafny.SeqWithoutIsStrInference([default__.AllCharactersSame((d_0_testStrings_)[d_2_i_])]))
            d_2_i_ = (d_2_i_) + (1)
        d_3_j_: int
        d_3_j_ = 0
        while (d_3_j_) < (len(d_1_results_)):
            if (d_1_results_)[d_3_j_]:
                _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "All characters are the same.\n"))).VerbatimString(False))
            elif True:
                _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "Different characters.\n"))).VerbatimString(False))
            d_3_j_ = (d_3_j_) + (1)

