import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_
import PowerLogs as PowerLogs

# Module: module_

# PROOF2SILICON_APPENDED_GENERATED_MODULES


# ============================================================
# Appended from Dafny-generated file: PowerLogs.py
# ============================================================
import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: PowerLogs

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def pow_(base, exp):
        d_0___accumulator_ = 1
        while True:
            with _dafny.label():
                if (exp) == (0):
                    return (1) * (d_0___accumulator_)
                elif True:
                    d_0___accumulator_ = (d_0___accumulator_) * (base)
                    in0_ = base
                    in1_ = (exp) - (1)
                    base = in0_
                    exp = in1_
                    raise _dafny.TailCall()
                break

    @staticmethod
    def power(base, exp):
        res: int = int(0)
        d_0_i_: int
        d_0_i_ = 0
        res = 1
        while (d_0_i_) < (exp):
            res = (res) * (base)
            d_0_i_ = (d_0_i_) + (1)
        return res

    @staticmethod
    def log__floor(n):
        lf: int = int(0)
        d_0_currentPow_: int
        d_0_currentPow_ = 1
        lf = 0
        while ((d_0_currentPow_) * (2)) <= (n):
            d_0_currentPow_ = (d_0_currentPow_) * (2)
            lf = (lf) + (1)
        return lf

    @staticmethod
    def log__floor__floor(n):
        res: int = int(0)
        d_0_lf_: int
        out0_: int
        out0_ = default__.log__floor(n)
        d_0_lf_ = out0_
        if (d_0_lf_) > (0):
            out1_: int
            out1_ = default__.log__floor(d_0_lf_)
            res = out1_
        elif True:
            res = 0
        return res

    @staticmethod
    def log__floor__div(n, d):
        res: int = int(0)
        d_0_q_: int
        d_0_q_ = _dafny.euclidian_division(n, d)
        out0_: int
        out0_ = default__.log__floor(d_0_q_)
        res = out0_
        return res

    @staticmethod
    def log__floor__div__floor(n, d):
        res: int = int(0)
        d_0_q_: int
        d_0_q_ = _dafny.euclidian_division(n, d)
        d_1_lf_: int
        out0_: int
        out0_ = default__.log__floor(d_0_q_)
        d_1_lf_ = out0_
        if (d_1_lf_) > (0):
            out1_: int
            out1_ = default__.log__floor(d_1_lf_)
            res = out1_
        elif True:
            res = 0
        return res
