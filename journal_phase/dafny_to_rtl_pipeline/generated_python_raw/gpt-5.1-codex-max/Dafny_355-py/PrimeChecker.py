import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: PrimeChecker

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def IsPrime(n):
        result: bool = False
        d_0_k_: int
        d_0_k_ = 2
        result = True
        while (d_0_k_) < (n):
            if (_dafny.euclidian_modulus(n, d_0_k_)) == (0):
                result = False
                return result
            d_0_k_ = (d_0_k_) + (1)
        return result
        return result

    @staticmethod
    def Main(noArgsParameter__):
        d_0_n_: int
        d_0_n_ = 17
        d_1_isP_: bool
        out0_: bool
        out0_ = default__.IsPrime(d_0_n_)
        d_1_isP_ = out0_
        if d_1_isP_:
            _dafny.print(_dafny.string_of(d_0_n_))
            _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, " is prime.\n"))).VerbatimString(False))
        elif True:
            _dafny.print(_dafny.string_of(d_0_n_))
            _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, " is not prime.\n"))).VerbatimString(False))

