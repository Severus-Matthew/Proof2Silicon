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
    def NeighborhoodIndex(left, center, right):
        return (((4 if left else 0)) + ((2 if center else 0))) + ((1 if right else 0))

    @staticmethod
    def ApplyStep(rule, curr, next_):
        d_0_i_: int
        d_0_i_ = 0
        while (d_0_i_) < ((curr).length(0)):
            d_1_left_: bool
            d_1_left_ = False
            if (d_0_i_) > (0):
                d_1_left_ = (curr)[(d_0_i_) - (1)]
            d_2_center_: bool
            d_2_center_ = (curr)[d_0_i_]
            d_3_right_: bool
            d_3_right_ = False
            if ((d_0_i_) + (1)) < ((curr).length(0)):
                d_3_right_ = (curr)[(d_0_i_) + (1)]
            d_4_idx_: int
            d_4_idx_ = default__.NeighborhoodIndex(d_1_left_, d_2_center_, d_3_right_)
            (next_)[(d_0_i_)] = (rule)[d_4_idx_]
            d_0_i_ = (d_0_i_) + (1)

    @staticmethod
    def PrintRow(row):
        d_0_i_: int
        d_0_i_ = 0
        while (d_0_i_) < ((row).length(0)):
            if (row)[d_0_i_]:
                _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "#"))).VerbatimString(False))
            elif True:
                _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "."))).VerbatimString(False))
            d_0_i_ = (d_0_i_) + (1)

    @staticmethod
    def Main(noArgsParameter__):
        d_0_length_: int
        d_0_length_ = 15
        d_1_steps_: int
        d_1_steps_ = 10
        d_2_current_: _dafny.Array
        nw0_ = _dafny.Array(False, d_0_length_)
        d_2_current_ = nw0_
        d_3_centerIndex_: int
        d_3_centerIndex_ = _dafny.euclidian_division(d_0_length_, 2)
        (d_2_current_)[(d_3_centerIndex_)] = True
        d_4_next_: _dafny.Array
        nw1_ = _dafny.Array(False, d_0_length_)
        d_4_next_ = nw1_
        d_5_rule30_: _dafny.Array
        nw2_ = _dafny.Array(False, 8)
        d_5_rule30_ = nw2_
        (d_5_rule30_)[(0)] = False
        (d_5_rule30_)[(1)] = True
        (d_5_rule30_)[(2)] = True
        (d_5_rule30_)[(3)] = True
        (d_5_rule30_)[(4)] = True
        (d_5_rule30_)[(5)] = False
        (d_5_rule30_)[(6)] = False
        (d_5_rule30_)[(7)] = False
        d_6_s_: int
        d_6_s_ = 0
        while (d_6_s_) < (d_1_steps_):
            default__.ApplyStep(d_5_rule30_, d_2_current_, d_4_next_)
            d_7_tmp_: _dafny.Array
            d_7_tmp_ = d_2_current_
            d_2_current_ = d_4_next_
            d_4_next_ = d_7_tmp_
            d_6_s_ = (d_6_s_) + (1)
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "Final state with Rule 30:\n"))).VerbatimString(False))
        default__.PrintRow(d_2_current_)
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\n"))).VerbatimString(False))
        nw3_ = _dafny.Array(False, d_0_length_)
        d_2_current_ = nw3_
        (d_2_current_)[(d_3_centerIndex_)] = True
        nw4_ = _dafny.Array(False, d_0_length_)
        d_4_next_ = nw4_
        d_8_rule90_: _dafny.Array
        nw5_ = _dafny.Array(False, 8)
        d_8_rule90_ = nw5_
        (d_8_rule90_)[(0)] = False
        (d_8_rule90_)[(1)] = True
        (d_8_rule90_)[(2)] = False
        (d_8_rule90_)[(3)] = True
        (d_8_rule90_)[(4)] = True
        (d_8_rule90_)[(5)] = False
        (d_8_rule90_)[(6)] = True
        (d_8_rule90_)[(7)] = False
        d_6_s_ = 0
        while (d_6_s_) < (d_1_steps_):
            default__.ApplyStep(d_8_rule90_, d_2_current_, d_4_next_)
            d_9_tmp2_: _dafny.Array
            d_9_tmp2_ = d_2_current_
            d_2_current_ = d_4_next_
            d_4_next_ = d_9_tmp2_
            d_6_s_ = (d_6_s_) + (1)
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "Final state with Rule 90:\n"))).VerbatimString(False))
        default__.PrintRow(d_2_current_)
        _dafny.print((_dafny.SeqWithoutIsStrInference(map(_dafny.CodePoint, "\n"))).VerbatimString(False))

