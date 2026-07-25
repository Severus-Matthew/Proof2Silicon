import sys
from typing import Callable, Any, TypeVar, NamedTuple
from math import floor
from itertools import count

import module_ as module_
import _dafny as _dafny
import System_ as System_

# Module: CountListsModule

class default__:
    def  __init__(self):
        pass

    @staticmethod
    def CountLists(lists):
        count: int = int(0)
        d_0_c_: int
        d_0_c_ = 0
        d_1_i_: int
        d_1_i_ = 0
        while (d_1_i_) < (len(lists)):
            d_0_c_ = (d_0_c_) + (1)
            d_1_i_ = (d_1_i_) + (1)
        count = d_0_c_
        return count

    @staticmethod
    def Check():
        d_0_s_: _dafny.Seq
        d_0_s_ = _dafny.SeqWithoutIsStrInference([_dafny.SeqWithoutIsStrInference([1, 2]), _dafny.SeqWithoutIsStrInference([]), _dafny.SeqWithoutIsStrInference([3, 4, 5])])
        d_1_cnt_: int
        out0_: int
        out0_ = default__.CountLists(d_0_s_)
        d_1_cnt_ = out0_
        d_2_emptySeq_: _dafny.Seq
        d_2_emptySeq_ = _dafny.SeqWithoutIsStrInference([])
        d_3_cntEmpty_: int
        out1_: int
        out1_ = default__.CountLists(d_2_emptySeq_)
        d_3_cntEmpty_ = out1_
        d_4_singleElementSeq_: _dafny.Seq
        d_4_singleElementSeq_ = _dafny.SeqWithoutIsStrInference([_dafny.SeqWithoutIsStrInference([1])])
        d_5_cntSingle_: int
        out2_: int
        out2_ = default__.CountLists(d_4_singleElementSeq_)
        d_5_cntSingle_ = out2_
        d_6_multiSeq_: _dafny.Seq
        d_6_multiSeq_ = _dafny.SeqWithoutIsStrInference([_dafny.SeqWithoutIsStrInference([1, 2]), _dafny.SeqWithoutIsStrInference([3, 4]), _dafny.SeqWithoutIsStrInference([5])])
        d_7_cntMulti_: int
        out3_: int
        out3_ = default__.CountLists(d_6_multiSeq_)
        d_7_cntMulti_ = out3_

